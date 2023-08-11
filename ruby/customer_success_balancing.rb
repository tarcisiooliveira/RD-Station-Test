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
    cs_index = 0
    most_efficient_cs_id = nil
    second_most_efficient_cs_id = nil
    ordered_clients.map do |client|

      # p client
      # p avaliable_CS
      # p '-------'
      # update_count_cs(cs_index, client[:score])
      if client[:score] <= avaliable_CS[cs_index][:score]
        update_count_cs(cs_index)
      else
        cs_index += 1
        update_count_cs(cs_index) if cs_index <= cs_size_array
      end
    end
    p avaliable_CS

    # if cs_index < avaliable_CS.size
    #   most_efficient_cs_id, second_most_efficient_cs_id = check_most_efficient_cs(most_efficient_cs_id, cs_index)
    # end

    # check_draw(most_efficient_cs_id, second_most_efficient_cs_id)
  end

  def cs_size_array
    @cs_size_array ||= avaliable_CS.size
  end

  def check_draw(most_efficient, second_must_efficient)
    return 0 if most_efficient.eql?(second_must_efficient)

    most_efficient
  end


  def create_keys(index)
    avaliable_CS[index][:count_client] = 0
  end

  def check_most_efficient_cs(most_efficient, candidate)
    return [candidate, nil] if most_efficient.nil?

    if avaliable_CS[most_efficient][:count_client] >= avaliable_CS[candidate][:count_client]
      [most_efficient, candidate]
    else
      [candidate, most_efficient]
    end
  end

  def update_count_cs(index)
    create_keys(index) unless avaliable_CS[index][:count_client]

    avaliable_CS[index][:count_client] += 1
  end

# precisa validar que o numero de cs fora de atividde tem que ser no máximo o numero de cs/2 arredondado para baixo
  def ordered_clients
    @ordered_clients ||= begin
      @customers.sort! {|first_customer, second_customer| first_customer[:score] <=> second_customer[:score] }
      # @customers.reverse!
    end
  end

  def avaliable_CS
    @avaliable_CS ||= begin
      @customer_success.reject! { |cs| @away_customer_success.include?(cs[:id]) }
      @customer_success.sort! {|first_cs, second_cs| first_cs[:score] <=> second_cs[:score] }
      # @customer_success.reverse!
    end
  end

  def avaliable_cs_count
    @avaliable_cs_count ||= avaliable_CS.length
  end
end

class CustomerSuccessBalancingTests < Minitest::Test
  # def test_scenario_one
  #   balancer = CustomerSuccessBalancing.new(
  #     build_scores([60, 20, 95, 75]),
  #     build_scores([90, 20, 70, 40, 60, 10]),
  #     [2, 4]
  #   )
  #   assert_equal 1, balancer.execute
  # end

  def test_scenario_two
    balancer = CustomerSuccessBalancing.new(
      build_scores([11, 21, 31, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  # def test_scenario_three
  #   balancer = CustomerSuccessBalancing.new(
  #     build_scores(Array(1..999)),
  #     build_scores(Array.new(10000, 998)),
  #     [999]
  #   )
  #   result = Timeout.timeout(1.0) { balancer.execute }
  #   assert_equal 998, result
  # end

  # def test_scenario_four
  #   balancer = CustomerSuccessBalancing.new(
  #     build_scores([1, 2, 3, 4, 5, 6]),
  #     build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
  #     []
  #   )
  #   assert_equal 0, balancer.execute
  # end

  # def test_scenario_five
  #   balancer = CustomerSuccessBalancing.new(
  #     build_scores([100, 2, 3, 6, 4, 5]),
  #     build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
  #     []
  #   )
  #   assert_equal 1, balancer.execute
  # end

  # def test_scenario_six
  #   balancer = CustomerSuccessBalancing.new(
  #     build_scores([100, 99, 88, 3, 4, 5]),
  #     build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
  #     [1, 3, 2]
  #   )
  #   assert_equal 0, balancer.execute
  # end

  # def test_scenario_seven
  #   balancer = CustomerSuccessBalancing.new(
  #     build_scores([100, 99, 88, 3, 4, 5]),
  #     build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
  #     [4, 5, 6]
  #   )
  #   assert_equal 3, balancer.execute
  # end

  # def test_scenario_eight
  #   balancer = CustomerSuccessBalancing.new(
  #     build_scores([60, 40, 95, 75]),
  #     build_scores([90, 70, 20, 40, 60, 10]),
  #     [2, 4]
  #   )
  #   assert_equal 1, balancer.execute
  # end

  private

  def build_scores(scores)
    scores.map.with_index do |score, index|
      { id: index + 1, score: score }
    end
  end
end
