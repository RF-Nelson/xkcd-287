class ProblemData
  attr_reader :total
  attr_reader :total_string
  attr_reader :item_names
  attr_reader :item_prices
  attr_reader :file_name

  def initialize(file_contents, file_name)
    @file_name = file_name
    @total = currency_to_int(file_contents[0])
    @total_string = file_contents[0]
    @item_names = []
    @item_prices = []
    process_items(file_contents[1..-1])
  end

  private

    def process_items(items)
      items.each do |item|
        split_str = item.split(",")
        @item_names << split_str[0]
        @item_prices << currency_to_int(split_str[1])
      end
    end

    def currency_to_int(str)
      int_price = str.gsub(/\D/, '').to_i
      fail ArgumentError.new('Item prices must be greater than zero') if int_price < 1
      int_price
    end
end
