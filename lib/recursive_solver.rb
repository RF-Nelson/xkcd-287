require "benchmark"

class RecursiveSolver
  include Solver

  def solve(problem_set, verbose=true, memoized=true)
    @problem_set = problem_set
    @solutions = []
    @cache = {} if memoized
    @sets_considered = 0

    iterate(0, [], memoized)
    
    @solutions.uniq! if !memoized

    processed_solutions = []
    @solutions.each do |solution|
      processed_solutions << process_solution(solution)
    end

    @solutions = processed_solutions
    print_results(@solutions, problem_set, @sets_considered) if verbose
    return @solutions
  end

  private

    def iterate(sum, order, memoized)
      @problem_set.item_prices.each_with_index do |item_price, idx|
        next if memoized && item_price > @problem_set.total - sum
        new_order = (order + [idx]).sort
        order_string = new_order.to_s
        next if memoized && @cache[order_string]

        @cache[order_string] = true if memoized
        new_price = sum + item_price

        if new_price == @problem_set.total
          @solutions << new_order
        elsif new_price < @problem_set.total
          iterate(new_price, new_order, memoized)
        end

        @sets_considered += 1
      end
    end

    # This method returns an array of respective item quantities
    # ex: [0, 4, 4, 6] => [1, 0, 0, 0, 2, 0, 1]
    def process_solution(solution)
      quantity_array = Array.new(@problem_set.item_prices.length, 0)
      @problem_set.item_prices.each_index do |idx|
        quantity_array[idx] = solution.count(idx)
      end
      quantity_array
    end
end
