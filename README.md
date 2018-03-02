# XKCD #287

This is a small project to solve the problem proposed in the [following xkcd comic](https://xkcd.com/287/):
<br><div align="center"><img src="https://www.explainxkcd.com/wiki/images/0/0e/np_complete.png"/><br><br></div>

## Usage

This is a simple command-line application that expects input from a text file and prints the results to the console.

### File Format

This command-line app parses a `.txt` file with the desired total in the first line and the menu options on the following lines. If we were to take the example from the xkcd comic and format it in this way, it would look like this:

```
$15.05
mixed fruit,$2.15
french fries,$2.75
side salad,$3.35
hot wings,$3.55
mozzarella sticks,$4.20
sampler plate,$5.80
```

### Processing a File

To process a file named `menu.txt`, run the following command in the root of the project:

```
ruby xkcd287.rb menu.txt
```

To process multiple files, provide multiple command-line arguments for each file, like so:

```
ruby xkcd287.rb menu.txt other_menu.txt
```

To process all `.txt` files within the root directory, simply run:

```
ruby xkcd287.rb
```

### Expected Output

If we were to input the example demonstrated in the xkcd comic, the following would be printed to the console:

```
|---------------------------
| Results for file: menu.txt
|
| Solution #1 for menu.txt
|-----|---------------------
| Qty | Item Name
|-----|---------------------
|  7  | mixed fruit
|  0  | french fries
|  0  | side salad
|  0  | hot wings
|  0  | mozzarella sticks
|  0  | sampler plate
|---------------------------
|
| Solution #2 for menu.txt
|-----|---------------------
| Qty | Item Name
|-----|---------------------
|  1  | mixed fruit
|  0  | french fries
|  0  | side salad
|  2  | hot wings
|  0  | mozzarella sticks
|  1  | sampler plate
|---------------------------
```

If we were to try an example where there is no valid solution, we would see the following output to the console:

```
|---------------------------
| Results for file: menu.txt
|
| No combinations of items add up to $x.xx
|
|---------------------------
```
If you'd like to alter which method you're using, open the `xkcd287.rb` file in the root of this project and change which `Solver` methods are called when the program is run.

### Running the Test Suite

To run the `rspec` tests, make sure you have the `bundler` gem installed by running:
```
gem install bundler
```

Then, from within the root of this project run:
```
bundle install
```

You should now be able to run the tests located in the `/spec` folder by running:
```
bundle exec repec
```
## Similar Problems

As stated in the comic, this problem is similar to the [Knapsack problem](https://en.wikipedia.org/wiki/Knapsack_problem), which is [NP-complete](https://en.wikipedia.org/wiki/NP-completeness). More specifically, this is closely related to a [special version](https://en.wikipedia.org/wiki/Knapsack_problem#Subset-sum_problem) of the Knapsack problem. The goal of the traditional knapsack problem is to maximize the summed value of items in a knapsack with limited capacity by choosing items with different values and sizes. In the xkcd problem, there is no notion of 'value'; we only care about summing the price of the menu items to equal the desired total. Therefore, this version is a bit simpler than the true knapsack problem, as it is not [NP-Hard](https://en.wikipedia.org/wiki/NP-hardness) (assuming the menu items are fixed). This problem is also a re-wording of one particular variety of the ["making change"](https://www.geeksforgeeks.org/dynamic-programming-set-7-coin-change/) problem.


## Design

- File opening/reading is encapsulated into the `FileParser` class; the primary functionality of this class to abstract away the processing of one or more files of text
- After the file(s) have been processed, the text within each file is converted into an instance of `ProblemData`. The `ProblemData` class is constructed to contain instance viariables that represent each important piece of data. It also converts the decimal values on the menu to integers to avoid any unforseen consequences that might arise from using floating-point arithmetic. 
- The `Solver` module has an abstract `#solve` method which inheriting classes must implement, as well as a shared `#print_results` method.

## Algorithmic Analysis

Naturally, the initial goal is to get the correct answer regardless of computational complexity.

My naïve approach, as codified in the `IterativeSolution` class is as follows (in pseudocode):
```
possible_item_quantities = []
for each item_price in item_menu
  item_quantities = []
  quantity = 0
  while (item_price * quantity < target_price)
    item_quantities.push(quantity)
    quantity = quantity + 1

   possible_item_quantities.push(item_quantities)  

possible_combinations = all permutations of Arrays within possible_item_quantities

solutions = []
for combo in possible_combinations
  if the sum of the items in combo == target_price
    solutions.push(combo)
```

This solution leverages the [Array#product](http://ruby-doc.org/core-2.2.0/Array.html#method-i-product) method. The `Array` of `possible_combinations` will contain all permutations of possible answers. Ultimately, this will provide us with the correct answer but this algorithm will have tested 14,400 possible combinations in the case of the example presented in the xkcd comic and takes about 17 milliseconds to find all solutions. I think we can do better.

Perhaps a different approach to this problem would be more efficient.  

Here is a pseudocode version of the simple recursive solution the `RecursiveSolution#solve` method employs:
```
solutions = []

def iterate(sum, order=Array.new, item_prices, desired_total)
  for price in item_prices
    new_order = order.push(price)
    new_total = sum + price
    
    if new_total == desired_total
      solutions.push(new_order)
    else if new_total < desired_total
      iterate(new_total, new_order, item_prices, desired_total)
```
The `solutions` `Array` will contain valid item combinations that sum up to the `desired_total`. In the case of the example in the xkcd comic, the recursive function is called 12,072 times and, on average, it takes about 43 milliseconds to find all solutions. This is actually _worse_ than the iterative solution.

<br><div align="center"><img src="https://static.fjcdn.com/gifs/There_e4d782_5423043.gif"/><br><i><h2>There's got to be a better way!</h2></i><br></div>

### Memoization

With any recursive method, there will be a wasteful repetition of calculations. If we did not utilize the `Array#uniq!` method upon the non-memoized recursive soution, we would have a number of duplicate results. By maintaining a [memoized](https://en.wikipedia.org/wiki/Memoization) cache of calculated quantities, we can eliminate the repetitive branches of the recursive function. Each time a combination of items is considered, we check the cache to see if this combination has been considered before. If so, we skip it. If not, we add it to the cache and perform our calculations. This reduces the number of recursive calls to 576 and the average runtime of finding all solutions to the xkcd example to about 3.7ms.

### More Truncating

With memoization, we were able to truncate a ton of unneeded work. Can we do even better? Maybe we can eliminate some of the work right off the bat if we know the next item definitely won't work. Inside the loop that iterates through the item prices, if we insert the following line before anything else we will see signifcant performance gains:
```
  next if item_price > desired_total - sum
```
We are eliminating any further processing in the loop if the `item_price` is larger than the difference of the current `sum` and the `desired_total`. Can this simple one line really make a difference? As it turns out, it cuts our average runtime almost in half at 1.62ms!

## Final Thoughts

This was an interesting exercise. One could easily spend hours considering new ways to truncate additional unnecessary paths. In fact, one could easily spend hours *reading about* various dynamic programming methods with which to solve NP-complete challenges like the knapsack problem and the travelling salesman in [pseudo-polynomial time](https://en.wikipedia.org/wiki/Pseudo-polynomial_time). 

**Please feel free to submit a pull request with your improvements.**

### Tabulated Results

| Naïve Iteration  | Naïve Recursion | Memoized Recursion | Memoized/Truncated Recursion |
| ------------- | ------------- | ------------- | ------------- |
| 17.41ms  | 43.38ms  | 3.72ms  | 1.62ms  | 

The table above shows the runtime for solving the xkcd example, averaged over ten runs for each method. Ruby's [`Benchmark#realtime`](http://ruby-doc.org/stdlib-2.0.0/libdoc/benchmark/rdoc/Benchmark.html#method-c-realtime) method was used to calculate these numbers on a late 2013 MacBook Pro with an i7-4850HQ processor with 16gb of RAM running macOS High Sierra 10.13.2. 


### To Do
- [x] add rspec tests
- [ ] handling of command-line flags (`-i` to run iterative solution, `-rm` to run memoized recursive solution, a flag to compare the efficiency of different `Solver` classes, etc.)
- [ ] further leverage [dynamic programming](https://en.wikipedia.org/wiki/Dynamic_programming) techniques to improve performance
- [ ] re-examine the object-oriented design of the `Solver` module, as there is likely to be a more elegant solution
- [ ] general refactoring. Ruby has so many helpful built-in methods, there are probably a few instances where the code could be more terse.
