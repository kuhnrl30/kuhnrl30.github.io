---
title: "Writing Functions in VBA"
date: 2015-11-29
layout: post
comments: true
---

## Make life easier by using functions instead of complex equations

Excel is a very powerful tool for data analysis with many built in capabilities such as the Analysis Tool-Pack.  However, there are times when you want to do something Excel doesn't support or would be very complex to implement using the formula bar.  By using the power of VBA and user-defined functions, you can expand Excel's capabilities or to remove unnecessary complexity. The perfect use case is for nested formulas and if you've ever written a nested-IF formula, you know how difficult these can be.  If you are not familiar with the concept of nested formulas, they happen when you put one formula inside of another formula.  Consider the following example of several nested IF formulas.  

#### Situation
You are writing a formula that helps you decide what to drink based on the temperature.  If it's hot, say more than 80 degrees, you'll want to have a glass of iced tea.  If it's cold, say less than 60 degrees, then you'd want a hot cup of coffee to warm up with.  If it's neither hot nor cold, then you'd drink water. You have entered the temperature in cell A1.  

#### Use the Formula Method 
You could use the formula below to solve your problem.  Notice that there is an if-then formula nested inside of another if-then formula. When you start chaining these together like this it can be difficult to keep track what's happening.  On top of that, changing the location of your input from cell A1 means you have to change the formula each time cell A1 was referenced.

```
=if(A1>80,"Iced Tea",if(A1<60,"Coffee,"Water"))
``` 

#### Simplify By Writing a Function
You could simplify your formula by writing a function in VBA and calling that instead of the nested formulas. Functions also offer the flexibility to perform calculations that don't fit into the standard formulas. Since the user defines these new functions, they are appropriately referred to as User Defined Functions or UDFs. I find two major advantages from using VBA:

1. Use whitespace to break up the calculation and make it easier for you to read. 
2. Add comments to explain what you did and why you made those decisions

Here's how the function would look in VBA: 

```
Public Function ChooseDrink(x as double) as string
Dim strDrink as string

If x > 80 Then
		strDrink = "Iced Tea"	' Drink iced tea if it's hot
	Else if x < 60 
		strDrink = "Coffee"	' Drink coffee if it is cold
	Else
		strDrink = "Water"	' Drink water any other time
	End if
	
	ChooseDrink= strDrink

End Function
```

There's a lot happening there so let's break it down line by line.  In the first line you must tell Excel what the code is going to do; you declare that this block of code will be a function and then give it a name.  I'm calling this function ChooseDrink.  

Moving to the right we state the inputs to the function and place them within the parentheses.  There will be a single input which I'm calling 'x' but you can include many more inputs as needed.  Our input variable x will have the data type of double.  Just like Excel treats text and numbers differently, VBA will act differently on different data types. Double is used for decimal numbers. Other options are strings for a string of characters, integer for integers, and variant as a sort of wildcard.  Variants can take on any data type. I won't spend any more time on variable types, since that's probably a blog post on to itself. I'll finish the first line by stating the type of data the function will return.  

The second line declares the variable- strDrink- which we'll use within the function. The word dim simply is the declaration and allocates a certain amount of memory for the variable. Same as before, we have to decide the variable type which in our case is a string. We have just told Excel we need a variable called strDrink and the computer needs to reserve enough memory for it. One thing to note is that I've added the prefix str to the variable to remind me that the variable is of type string.  This isn't required but I'd recommend establishing a set of naming conventions and using those conventions consistently. 

Finally, we can get to the heart of the function with the if-then statement. We've used a series of logical statements which Excel will evaluate as either True or False and act accordingly.  If the statement x > 80 is true, then we set the value of our variable strDrink to 'Iced Tea'.  If the statement is not True, then we move through the else-if statement until something does evaluate to True or we hit the Else clause.  

Here's where you see the advantage of using a function over the formula.  First, the IF statement is in the same order as the description in the scenario.  It's organized in exactly the same order as the though process as opposed to the nested format. Secondly, we can add comments to explain our calculations.  Anything after the ' character is interpreted as a comment and is not evaluated. Comments can be incredibly valuable when reading someone else's code. If you had handed this code off to someone else to read such as a peer or manager, then you could make their job easier if your comments are descriptive and easy to follow.  

At the end of the function we have to tell Excel what to return to the user.  Recall that the function name is ChooseDrink.  We pass the strDrink variable back to the function using the = symbol.

To use the function, simply enter it in the cell as you would any other formula.

```
=ChooseDrink(A1)
``` 

The function clean and simple to use. Now granted, this wasn't the most complex example and you probably would be just fine using the formula bar. For the purpose of this demonstration, I think it helped to draw the parallels between the formula and the function. As you become comfortable using VBA, you can think of it as another tool in your toolbox.  It's up to you decide when its the best tool for the job. 