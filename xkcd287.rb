require_relative './lib/problem_data'
require_relative './lib/file_parser'
require_relative './lib/solver'
require_relative './lib/iterative_solver'
require_relative './lib/recursive_solver'

data_from_files = FileParser.process_files(ARGV)
problem_sets = []

data_from_files.each { |data| problem_sets << ProblemData.new(data[0], data[1]) }

if problem_sets.empty?
  puts('No files processed. Either place a .txt file in this directory or specify a file via command-line argument.')
else
  problem_sets.each do |problem_set|
    # IterativeSolver.new.solve(problem_set, true) # <- brute force iterative solution
    # RecursiveSolver.new.solve(problem_set, true, false) # <- recursive solution without memoization
    RecursiveSolver.new.solve(problem_set, true) # <- recursive solution WITH memoization and truncation
  end
end
