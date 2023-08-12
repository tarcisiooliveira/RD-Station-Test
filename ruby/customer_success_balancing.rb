require 'minitest/autorun'
require 'timeout'

class CustomerSuccessBalancing
  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  # Returns the ID of the customer success with most customers
  def execute
    customer_success_index = 0
    remove_low_level_cs
    return 0 if avaliable_customer_success.empty?

    ordered_clients.map do |client|
      if client[:score] > avaliable_customer_success[customer_success_index][:score]
        customer_success_index += 1
        break if customer_success_index >= customer_success_size_array
      end
      update_count_client(customer_success_index)
    end
    @avaliable_customer_success.sort! do |first_customer_success, second_customer_success|
      first_customer_success[:score] <=> second_customer_success[:score]
    end

    return_customer_success_id(@avaliable_customer_success[0], @avaliable_customer_success[1])
  end

  def remove_low_level_cs
    avaliable_customer_success.reject! { |cs| cs[:score] < ordered_clients[0][:score] }
  end

  def update_count_client(index)
    create_count_client_keys(index) unless avaliable_customer_success[index][:count_client]
    avaliable_customer_success[index][:count_client] += 1
  end

  def customer_success_size_array
    @customer_success_size_array ||= avaliable_customer_success.size
  end

  def return_customer_success_id(first_customer_success, second_customer_success)
    return first_customer_success[:id] if second_customer_success.nil? && first_customer_success.any?
    return 0 if first_customer_success[:count_client].eql?(second_customer_success[:count_client])

    first_customer_success[:id]
  end

  def create_count_client_keys(index)
    avaliable_customer_success[index][:count_client] = 0
  end

  def ordered_clients
    @ordered_clients ||= @customers.sort! do |first_customer_success, second_customer_success|
      first_customer_success[:score] <=> second_customer_success[:score]
    end
  end

  def avaliable_customer_success
    @avaliable_customer_success ||= begin
      @customer_success.reject! { |cs| @away_customer_success.include?(cs[:id]) }
      @customer_success.sort! do |first_customer_success, second_customer_success|
        first_customer_success[:score] <=> second_customer_success[:score]
      end
    end
  end
end

class CustomerSuccessBalancingTests < Minitest::Test
  def test_scenario_one
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 20, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    balancer = CustomerSuccessBalancing.new(
      build_scores([11, 21, 31, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    balancer = CustomerSuccessBalancing.new(
      build_scores(Array(1..999)),
      build_scores(Array.new(10_000, 998)),
      [999]
    )
    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 998, result
  end

  def test_scenario_four
    balancer = CustomerSuccessBalancing.new(
      build_scores([1, 2, 3, 4, 5, 6]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 2, 3, 6, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_six
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [1, 3, 2]
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_seven
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [4, 5, 6]
    )
    assert_equal 3, balancer.execute
  end

  def test_scenario_eight
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 40, 95, 75]),
      build_scores([90, 70, 20, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_nine
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 40, 80, 75]),
      build_scores([90]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_ten
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 40, 99, 75]),
      build_scores([90]),
      [3]
    )
    assert_equal 0, balancer.execute
  end

  private

  def build_scores(scores)
    scores.map.with_index do |score, index|
      { id: index + 1, score: score }
    end
  end
end
