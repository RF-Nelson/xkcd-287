require 'spec_helper'
require 'problem_data'

describe ProblemData, '#new' do
  let(:problem_data1) { ProblemData.new(['$5.00', 'item1, $2.50'], '_') }
  let(:problem_data2) { ProblemData.new(['$123.45', 'item2, $22.05', 'item3, $8.96'], '_') }

  it 'correctly reflects the total price as an integer' do
    expect(problem_data1.total).to eq(500)
    expect(problem_data2.total).to eq(12345)
  end

  it 'separately processes the correct number of items' do
    expect(problem_data1.item_names.length).to eq(1)
    expect(problem_data2.item_names.length).to eq(2)
  end

  it 'properly processes the item names' do
    expect(problem_data1.item_names[0]).to eq('item1')
    expect(problem_data2.item_names[0]).to eq('item2')
    expect(problem_data2.item_names[1]).to eq('item3')
  end

  it 'properly processes the item prices as integers' do
    expect(problem_data1.item_prices[0]).to eq(250)
    expect(problem_data2.item_prices[0]).to eq(2205)
    expect(problem_data2.item_prices[1]).to eq(896)
  end

  it 'raises an error if an item price is less than 0.01' do
    expect{ProblemData.new(['$123.45', 'item2, $22.05', 'item3, $0'], '_')}
      .to raise_error(ArgumentError)
  end
end
