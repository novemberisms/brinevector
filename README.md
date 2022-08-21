# brinevector
A simple vector lua library for everyone!

### Motivation
While looking for vector libraries for lua, I noticed most of them use tables to store the vectors themselves. This might be fine for most applications, but for games and high-performance uses, creating a table for every vector is simply too much overhead. Using C data to store and create vectors with the `ffi` library in luajit is a much more efficient method that can produce code that performs much faster and consumes a lot less memory. ([Depending on the application, around 35x less memory, and 20x better performance!](http://luajit.org/ext_ffi.html))

So I wrote this vector library to take advantage of that fact, and made it extremely beginner-friendly and easy for everybody to use. It's also designed to be lightweight and very portable; it's only really a single file!

And if the library detects that you're on a platform that does not fully support the `ffi` library, then it will automatically fall back to using your standard lua tables, meaning there are no downsides to sticking with brinevector when developing for mobile compared to other vector libraries.

### Compatibility
BrineVector was written for LOVE2D and is accelerated by the ffi module in luajit, but can be used for any luajit program.

##### Fallback to standard lua tables

This library takes advantage of the JIT compiler on desktop targets for LOVE2D. This gives a great performance boost to desktop applications, but for mobile and console platforms, the JIT is disabled because they do not allow execution of arbitrary runtime code.

The `ffi` library still works, but it takes much longer to call functions and marshal values between lua and C. Even longer than if brinevector used tables instead. This means that a mobile or console app would be better off falling back to a table implementation of vectors rather than using the `ffi` library.

Fortunately, brinevector is aware of this limitation, and will **automatically fall back to tables** if it detects that it's running on **mobile** or **consoles**. This gives you the same amount of performance as any other table-based vector library on mobile and consoles, but also gives you a tremendous boost to desktop games, all without having to do anything on your end.

# installation
Paste the `brinevector.lua` file and its accompanying `BRINEVECTOR_LICENSE` into your project.

Simply `require` the file in your projects and give the returned table a name
```lua
Vector = require "brinevector"
```
Or, 
```lua
local Vector = require "brinevector"
```
You can replace `Vector` with any name you wish to use. Even `V`, for brevity. If you gave it any other name than `Vector`, in all code examples that follow, replace `Vector` with whatever name you gave it in the `require` call.
# usage
[Here](https://github.com/novemberisms/brinevector/blob/master/cheatsheet.md) is an overview of all the features, properties, and methods of this library all in one place, and for most people, is everything they need to use this library. 

For beginners, or for anyone who wants more details, read the sections down below.

## Contents
-	[Instantiating a vector](#instantiating-a-vector)
-	[Accessing a vector's components](#accessing-a-vectors-components)
	  -	[Getting](#getting)
	  -	[Setting](#setting)
-	[Printing a Vector](#printing-a-vector)
-	[Vector Arithmetic](#vector-arithmetic)
	  -	[Addition and Subtraction](#addition-and-Subtraction)
	  -	[Multiplication with a scalar](#multiplication-with-a-scalar)
	  -	[Multiplication with another vector](#multiplication-with-another-vector)
	  -	[Division with a scalar](#division-with-a-scalar)
	  -	[Division with a vector](#division-with-a-vector)
	  -	[Negation](#negation)
-	[Vector Properties](#vector-properties)
	  -	[`length`](#length)
	  -	[`angle`](#angle)
	  -	[`normalized`](#normalized)
	  -	[`length2`](#length2)
	  -	[`inverse`](#inverse)
	  -	[`copy`](#copy)
	  -	[`floor`](#floor)
	  -	[`ceil`](#ceil)
-	[Vector Methods](#vector-methods)
	  -	[`getLength()`](#property-methods)
	  -	[`getAngle()`](#property-methods)
	  -	[`getNormalized()`](#property-methods)
	  -	[`getLengthSquared()`](#property-methods)
	  -	[`getInverse()`](#property-methods)
	  -	[`getCopy()`](#property-methods)
	  -	[`getFloor()`](#property-methods)
	  -	[`getCeil()`](#property-methods)
	  - [`dot(vector)`](#dot)
	  -	[`angled(theta)`](#angled)
	  -	[`rotated(theta)`](#rotated)
	  -	[`trim(length)`](#trim)
	-	[`hadamard(vector)`](#hadamard)
	-	[`split()`](#split)
	-	[`clamp(min, max)`](#clamp)
-	[Method Shortcuts](#method-shortcuts)
-	[Comparing Vectors with](#comparing-vectors-with-)`==`
-	[Checking if a variable is a Vector](#checking-if-a-variable-is-a-vector)
## Instantiating a vector
To create a new vector, just call the module directly
```lua
local myVec = Vector(3,4)
```
where 
-   the first argument will be the x-component of the new vector, 
-   and the second argument will be the y-component of the new vector.

If no arguments are given, then it defaults to creating a zero-vector. (x component equals `0` and y component equals `0`). Thus
```lua
local zVec = Vector()
```
is equivalent to 
```lua
local zVec = Vector(0,0)
```
## Accessing a vector's components
### Getting
Getting the x and y components of a vector works as you expect. 

If you have
```lua
local myVec = Vector(3,4)
```
then `myVec.x` and `myVec.y` will return the x and y components of `myVec`, respectively. 
(`3` and `4`)

```lua
print ( myVec.x )   -- prints "3"
print ( myVec.y )   -- prints "4"
```
### Setting
Assigning and modifying the x and y components is also straightforward
```lua
myVec.x = 10
myVec.y = 20
```
will set the x component of `myVec` to `10` and the y component to `20`
## Printing a vector
When using `tostring` or `print` on a vector, it will display in a readable format with 4 decimal places for each component. Thus,
```lua
local myVec = Vector(3,4)
print(myVec)
```
Outputs `"Vector{3.0000,4.0000}"`, and
```lua
local myOtherVec = Vector(1.123456,-3.141592)
local myStr = "the vector is " .. tostring(myOtherVec)
print(myStr)
```
Outputs `"the vector is Vector{1.1235,-3.1416}"`.

You can also concatenate strings with vectors with the `..` operator, thus
```lua
local velocity = Vector(123, 456)
print("my velocity is: " .. velocity)
```

## Vector Arithmetic
### Addition and Subtraction
You can add and subtract vectors using `+` and `-`
If you have
```lua
local a = Vector(3,4)
local b = Vector(1,2)
```
then
```lua
a + b       -- returns a vector <4,6>
a - b       -- returns a vector <2,2>
b - a       -- returns a vector <-2,-2>
a = a + b   -- a then becomes <4,6>
```

### Multiplication with a scalar
There are a few different types of vector multiplication. The simplest is multiplication of a vector with a number. 
```lua
local a = Vector(3,4)
a * 5           -- returns <15,20>
a * -1          -- returns <-3,-4>
3.1415 * a      -- returns <9.4245,12.5660>
local c = a * 2 -- instantiates a new vector with values <6,8>
```
### Multiplication with another vector
In some cases, you might want to get a vector whose x component is the product of two other vectors' x components, and whose y component is the product of their y components. (ie. "Component-wise" or "Freshman" multiplication). This is supported with a simple * syntax
```lua
local a = Vector(3,4)
local b = Vector(4,-2)
local c = a * b  -- c becomes <12,-8>
```
You can also do `a:hadamard(b)` if you care about accurate mathematical terminology. It works the same.
### Division with a scalar
Dividing a vector `V` with a scalar `x`, is exactly equivalent to multiplying `V` with `1/x`. Thus,
```lua
local a = Vector(3,4)
a / 5   -- returns <0.6,0.8>
```
### Division with a vector
In mathematics, there is no rule for dividing a vector with another vector, but because this library is mainly used in games, a division between vectors `vecA` and `vecB` produces a new vector whose components are the component-wise division of `vecA` and `vecB`
```lua
local a = Vector(1,1)
local b = Vector(5,5)
a / b -- equivalent to Vector(a.x / b.x, a.y / b.y)
```
##### NaN handling

If either of the divisor's components are `0` then vector division will produce a `NaN`, which this library treats as an error, because in LOVE2D, many bugs are caused by hidden `NaN`s allowed to propagate.

### Negation
A vector preceded by the unary minus operation (like `-v`, where `v` is a vector) is exactly equivalent to `v * -1`
```lua
local a = Vector(3,4)
-a      -- returns <-3,-4>
-a * 5  -- returns <-15,-20>
```

### Modulo
A vector can be made to undergo a modulo operation with either a scalar or another vector. 
```lua
-- with scalar
local a = Vector(10, 4)
local b = a % 3 -- b is <1, 1>
local c = 33 % a -- c is <3, 1>

-- with vector
local x = Vector(13, 17)
local y = Vector(2, 3)
x % y -- result is <1, 2>
```
Note that the result will be different if you swap the values of the two operands. (In other words, x % y is not the same as y % x, and this is also applies to vectors under this operation)

## Vector properties
For maximum convenience and ease of use, the most common properties of a vector are accessed just like any members of a table, **_without having to call any methods_** like in other libraries.

These are:
-   `length`
-   `angle`
-   `normalized`
-   `length2`
-   `inverse`
-   `copy`
### length
You can access the length of a vector with `.length` or by using the lua `#` operator. 
Thus if you have

```lua
local myVec = Vector(3,4)
```
then
```lua
myVec.length
```
produces `5`. 

```lua
#myVec
```

will also produce `5`

Even if you edit the vector later on, accessing the `length` property automatically computes the new length. This makes code shorter and more understandable. This is true for all the other special properties. They are generated on the fly when you ask for them.

```lua
local myVec = Vector(3,4)
local a = myVec.length        -- a becomes '5'
myVec = myVec * 3             -- myVec is now <9,12>
local b = myVec.length        -- b becomes '15'
```
Notice how you don't need to use a method like `a:length()` or `a:getLength()`. 
You simply use `a.length`
### angle
Using `.angle` gives the angle of a vector in radians
```lua
local myVec = Vector(1,1)
myVec.angle     -- produces PI/4 radians, or 0.78539816339744828
```
### normalized
Using `.normalized` gives the normalized vector of a given vector. That is, a vector with the same angle as the original, but whose length is `1`.
```lua
local myVec = Vector(3,4)
local myVecN = myVec.normalized    -- myVecN becomes <0.6,0.8>
myVecN.length                      -- is '1'
```
### length2
For most purposes (like comparing the lengths of vectors) you only need to compare the squares of the lengths of the vectors. This is because to get the length, any library needs to call `math.sqrt`. This can be slow, and so if you're conscious about performance, you can use `.length2`, which returns the length of a vector squared
```lua
-- compare the lengths of two vectors
local bakery = Vector(3,4)
local restaurant = Vector(10,10)

if bakery.length2 < restaurant.length2 then
    print("The bakery is closer")
elseif bakery.length2 > restaurant.length2 then
    print("The restaurant is closer")
end
-- outputs "The bakery is closer"
```
### inverse
Gets the component-wise multiplicative inverse of the vector. For a vector `(x, y)`, it's inverse will be `(1 / x, 1 / y)`
```lua
local newVec = myVec.inverse
```
is the same as 
```lua
local newVec = Vector(1 / myVec.x, 1 / myVec.y)
```
### copy
Produces a copy of the vector with the same x and y values, but with a different memory address. This allows passing vectors by copy instead of by reference.

Lua by default passes cdata like these vectors by reference, which can cause many kinds of bugs. To avoid these, when assigning vectors, try using `vecA = vecB.copy`. 

### floor

Gives the vector that would be formed by taking the `math.floor`results of the `x` and `y` components of a vector

```lua
local myVec = Vector(1.123, 5.234)
print( myVec.floor )
-> Vector{1.0000, 5.0000}
```

### ceil

Gives the vector that would be formed by taking the `math.ceil`results of the `x` and `y` components of a vector

```lua
local myVec = Vector(1.123, 5.234)
print( myVec.ceil )
-> Vector{2.0000, 6.0000}
```

## Vector methods
### Property methods
If you prefer getting the above properties with methods instead like in other libraries, you can always still use the following:
-   `myVec:getLength()`   -- equivalent to `myVec.length`
-   `myVec:getAngle()`    -- equivalent to `myVec.angle`
-   `myVec:getNormalized()` -- equivalent to `myVec.normalized`
-   `myVec:getLengthSquared()`  -- equivalent to `myVec.length2`
-   `myVec:getInverse()`	-- equivalent to `myVec.inverse`
-   `myVec:getCopy()`	-- equivalent to `myVec.copy`
-   `myVec:getFloor()`   -- equivalent to `myVec.floor`
-   `myVec:getCeil()`   -- equivalent to `myVec.ceil`

### dot
###### `myVec:dot( vector )`
This returns a scalar which is the "dot" product with another vector. The formula is as follows:
```lua
-- A dot product of two vectors A and B is equal to (A.x * B.x) + (A.y * B.y)
local a = Vector(3,4)
local b = Vector(6,3)
local result = a:dot(b) -- result is 30
assert(result == a.x * b.x + a.y * b.y)
```

### angled
###### `myVec:angled( angle )`
This returns a vector whose length is the same as `myVec` but whose angle is set to `angle` (in radians). For example,
```lua
local a = Vector(3,4)
local b = a:angled(0)
```
will set `b` to a vector with length `5` and whose angle is `0`. ie. `<5,0>`

This is equivalent to 
```lua
local a = Vector(3,4)
local b = Vector(a.length*math.cos(0), a.length*math.cos(0))
```

### rotated
###### `myVec:rotated( angle )`
This returns a vector whose angle is equal to the current angle of `myVec` plus `angle`. 

For instance, if `myVec` has a length of `5` and whose angle is  `PI` radians, then `myVec:rotated( math.pi )` will give a vector whose length is still `5` but whose angle is `2 * PI` radians. 

```lua
-- vector pointing 45 degrees with length sqrt(2)
local myVec = Vector(1, 1) 

-- rotate it +45 degrees more
local rotatedVec = myVec:rotated(math.pi / 4) 
print(rotatedVec)
> "Vector{0.0000,1.4142}" -- length is same, but angle is now 90 degrees
```

### trim
###### `myVec:trim( length )`
This returns a vector with the same angle as `myVec`, but whose length is "trimmed" down to `length` only if it is longer than `length`. 

That is, if the length of `myVec` is greater than `length`, then the returned vector will have length `length`. If the length of `myVec` is less than `length` then it will return a vector identical to `myVec`

```lua
local a = myVec:trim( 10 )
```
is equivalent to the following code:
```lua
local a = Vector(myVec.x, myVec.y)
if a.length > 10 then
    a = a.normalized * 10
end
```
This is useful for applying max velocity to an accelerating object. For example if you're updating the velocity `vel` of an object with acceleration `acc`, and whose speed must be capped to `MAXSPEED`, you can write,
```lua
vel = (vel + acc):trim(MAXSPEED)
```
instead of 
```lua
vel = vel + acc
if vel.length > MAXSPEED then
    vel = vel.normalized * MAXSPEED
end
```
### hadamard
###### `myVec:hadamard( otherVec )`
This returns a vector that is the result of a component-wise multiplication between `myVec` and `otherVec`. Thus `a = b:hadamard(c)` is equivalent to
```lua
a = Vector( b.x * c.x, b.y * c.y )
```
Alternatively, you can use `a = b * c`.

### split
###### `myVec:split( )`
This returns two values: the x component of the vector, and the y component of the vector.
Thus,

```lua
local x, y = myVec:split()
```
is equivalent to 
```lua
local x, y = myVec.x, myVec.y
```
### clamp
###### `myVec:clamp(min, max)`

This clamps the vector `myVec` per component between `min` and `max`

That is, 

```lua
myVec:clamp(vecA, vecB)
```

 is equivalent to

```lua
myVec = Vector(
    clamp(myVec, vecA.x, vecB.x),
    clamp(myVec, vecA.y, vecB.y)
)
```

where `clamp` is defined as follows:

```lua
-- if value is less than min, returns min
-- if value is greater than max, returns max
-- else, returns value
local function clamp(value, min, max)
    return math.min(math.max(min, value), max)
end
```

Think of it like you're clamping a vector to be within a rectangle whose top left edge is at `vecA` and whose bottom right edge is at `vecB`. This is very common when implementing cameras with set limits as to how far it can go.

## Method Shortcuts

Vectors can also be directly modified through their `length` and `angle` properties. This makes for some very short code.

If you have
```lua
myVec = Vector(3,4)
```
, and you want to modify it such that it keeps its direction but its length changes to `20`, then you can simply do
```lua
myVec.length = 20
```
And now if you inspect `myVec`,
```lua
"Vector{12.0000,16.0000}"
```
This is equivalent to 
```lua
myVec = myVec.normalized * 20
```
---
Similarly, if you have a vector
```lua
myUnitVec = Vector(1,0)
```
And you want it to point to an angle called `someangle`, but still have a length of 1, then simply do
```lua
myUnitVec.angle = someangle
```
This is equivalent to
```lua
myUnitVec = myUnitVec:angled(someangle)
```

## Comparing vectors with `==`
Vectors can be compared with any other data using `==`. 

`myVec == something` will only return `true` if 
-   `something` is another vector and
-   `something.x` == `myVec.x` and
-   `something.y` == `myVec.y`

Otherwise, it will return `false`
## Checking if a variable is a vector
Use __`Vector.isVector(x)`__ to check if `x` is a vector instantiated from the table returned by `require "brinevector"`.
# license

>Copyright 2018 'novemberisms'
>
>Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
>The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
