module Solver
  def solve(problem_set)
    fail NotImplementedError, 'Classes that inherit the "Solver" module must implement #solve'
  end

  private

    def print_results(solutions, problem_set, iteration_count)
      border = '|---------------------------'
      puts(border)
      puts("| Results for file: #{problem_set.file_name}")
      if solutions.empty?
        puts("|\n| No combinations of items add up to #{problem_set.total_string}|")
        puts(border)
      else
        solutions.each_with_index do |solution, idx|
          puts("|\n| Solution ##{idx + 1} for #{problem_set.file_name}")
          divider = '|-----|---------------------'
          puts(divider)
          puts("| Qty | Item Name")
          puts(divider)

          solution.each_with_index do |coefficient, idx|
            puts("|  #{coefficient}  | #{problem_set.item_names[idx]}")
          end
          puts(border)
        end
      end

      puts("\n#{iteration_count} item combinations were considered with the #{self.class}.\n\n")
    end
end
