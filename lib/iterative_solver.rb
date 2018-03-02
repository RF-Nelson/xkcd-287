# This class computes the answer by computing an array of possibilities to
# test. First, it goes through each item in the menu and calculates the
# maximum quantity. If we are considering an item priced at $5.00 and a
# desired total of $11.00, the possible quantities of our item in any valid
# combination could no exceed 2 becuase $5 * 3 > $11. An array of possible
# quantities for the $5 item would be [0, 1, 2]. We calculate this array of
# possible quantities for each item on the menu, then utilize the Array#product
# method to produce a 2d array that contains all possible permutations of the
# different combinations of items. Each possible item combination is compared to
# the total and any matching combinations are stored.
class IterativeSolver
  include Solver

  def solve(problem_set, verbose=true)
    # derive a list of different possible menu item combinations
    possibilities = get_matrix_of_possibilities(problem_set)

    # test if each possible item combination sums to the desired total
    @solutions = []
    possibilities.each do |possibility|
      sum = 0

      possibility.each_with_index do |coefficient, idx|
        sum += coefficient * problem_set.item_prices[idx]
      end

      @solutions << possibility if sum == problem_set.total
    end

    print_results(@solutions, problem_set, possibilities.count) if verbose
    return @solutions
  end

  private
    # returns a 2d array of different menu item quantity combinations
    def get_matrix_of_possibilities(problem_set)
      possibilities = []

      problem_set.item_prices.each do |price|
        possibilities << find_possible_quantities(price, problem_set.total)
      end

      possibilities = possibilities[0].product(*possibilities[1..-1])
      possibilities
    end

    # returns an array with possible item quantities
    # ex: if cost = 5 and total = 26 => [0,1,2,3,4,5] because 6 * 5 > total
    def find_possible_quantities(cost, total)
      possible_values = [0]
      return possible_values if cost > total

      counter = 1

      until counter * cost > total
        possible_values << counter
        counter += 1
      end

      possible_values
    end
  end
