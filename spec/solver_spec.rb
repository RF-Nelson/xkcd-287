require 'spec_helper'
require 'solver'
require 'iterative_solver'
require 'recursive_solver'
require 'problem_data'
require 'file_parser'

examples = %w(simple_menu no_solution_menu xkcd_example)
problem_data_sets = []

examples.each_with_index do |file, idx|
  parsed_file = FileParser.process_files(["./spec/examples/#{file}.txt"])
  problem_data_sets << ProblemData.new(parsed_file[0][0], parsed_file[0][1])
end

solvers = [IterativeSolver, RecursiveSolver]

solvers.each do |solver|
  describe solver, '#solve' do
    solutions1 = solver.new.solve(problem_data_sets[0], false)
    solutions2 = solver.new.solve(problem_data_sets[1], false)
    solutions3 = solver.new.solve(problem_data_sets[2], false)

    it 'correctly identifies valid number of solutions' do
      expect(solutions1.length).to eq(3)
      expect(solutions3.length).to eq(2)
    end

    it 'identifies the correct solutions' do
      solutions = [[0, 0, 2], [1, 0, 1], [2, 0, 0]]
      solutions.each { |sol| expect(solutions1.include?(sol)).to eq(true) }

      solutions = [[7, 0, 0, 0, 0, 0], [1, 0, 0, 2, 0, 1]]
      solutions.each { |sol| expect(solutions3.include?(sol)).to eq(true) }
    end

    it 'correctly identifies problems that have no solution' do
      expect(solutions2.length).to eq(0)
    end
  end
end
