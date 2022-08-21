Lines beginning with `->` are outputs of a lua interpreter.

##### Basic
```lua
-- assign a namespace
local Vector = require "brinevector"  

-- declare a new vector
local myVec = Vector(3,4) 

-- print and tostring
print(myVector) 
-> "Vector{3.0000,4.0000}"
tostring(myVector)
-> "Vector{3.0000,4.0000}"

-- access x component
myVec.x
-> 3

-- access y component
myVec.y									
-> 4

-- getting the length
#myVec
-> 5

-- modifying a vector
myVec.x = -100							
myVec.y = 25.5
print(myVec)
-> "Vector{-100.0000,25.5000}"
```
##### Arithmetic
```lua
local a = Vector(1,2)
local b = Vector(3,4)

-- addition
a + b									
-> "Vector{4.0000,6.0000}"

-- subtraction
a - b									
-> "Vector{-2.0000,-2.0000}"

-- scalar multiplication
a * 2									
-> "Vector{2.0000,4.0000}"

-- componentwise multiplication
a * b									
-> "Vector{3.0000,8.0000}

-- dot multiplication
a:dot(b)									
-> 11

-- scalar division
a / 2									
-> "Vector{0.5000,1.0000}"	

-- componentwise division
a / b
-> "Vector{0.3333,0.5000}"

-- unary negation
-a										
-> "Vector{-1.0000,-2.0000}"

-- modulo
b % 2
-> "Vector{1.0000,0.0000}"

Vector(10,7) % b
-> "Vector{1.0000,3.0000}"


```
##### Properties
```lua
myVec = Vector(3,4)

-- get length property
myVec.length							
-> 5

-- no need for methods like myVec:length()
myVec = Vector(6,8)						
myVec.length
-> 10

-- get angle in radians
myVec.angle								
-> 0.92729521800161219

-- get normalized vector
myVec.normalized						
-> "Vector{0.6000,0.8000}"

-- get componentwise inverse
myVec.inverse
-> "Vector{0.1667,0.1250}"

-- make copy of vector
myVec.copy
-> "Vector{6.0000,8.0000}"

-- get the floor of a vector
local fracVec = Vector(1.234, 5.678)
fracVec.floor
-> "Vector{1.0000,5.0000}"

-- get the ceil of a vector
fracVec.ceil
-> "Vector{2.0000,6.0000}"

-- chaining properties
myVec.normalized.length					
-> 1.000000023841858

myVec = Vector(3,4)		

-- get length squared
myVec.length2							
-> 25
```
##### Methods
```lua
a = Vector(5,5)

-- equivalent to a.length
a:getLength()							
-> 7.0710678118654755

-- equivalent to a.angle
a:getAngle()							
-> 0.78539816339744828

-- equivalent to a.normalized
a:getNormalized()						
-> "Vector{0.7071,0.7071}"

-- equivalent to a.length2
a:getLengthSquared()					
-> 50

-- equivalent to a.inverse
a:getInverse()
-> "Vector{0.2000,0.2000}

-- equivalent to a.copy
a:getCopy()
-> "Vector{5.0000,5.0000}

-- equivalent to a.floor
a:getFloor()
-> "Vector{5.0000,5.0000}"

-- equivalent to a.ceil
a:getCeil()
-> "Vector{5.0000,5.0000}"

-- vector that would result from rotating 'a' to 0 degrees
a:angled(0)								
-> "Vector{7.0711,0.0000}"

-- vector that would result from further rotating 'a' by 180 degrees
a:rotated(math.pi)
-> "Vector{-5.0000,-5.0000}"

-- result if vector 'a' trimmed until it is length 1.4142165 or less
a:trim(1.4142165)						
-> "Vector{1.0000,1.0000}"

-- identical if a.length < 100
a:trim(100)								
-> "Vector{5.0000,5.0000}"

-- componentwise multiplication
a:hadamard(Vector(2,3))					
-> "Vector{10.0000,15.0000}"

-- clamping a vector between two bounding vectors
local topleft = Vector(0, 0)
local botright = Vector(10, 10)
local b = Vector(-100, 300)
b:clamp(topleft, botright)
-> "Vector{0.0000,10.0000}"
```
##### Method Shortcuts
```lua
myVec = Vector(3,4)

-- equivalent to myVec = myVec:angled(0)
myVec.angle = 0							
print(myVec)
-> "Vector{5.0000,0.0000}"

myVec = Vector(0.6,0.8)
	
-- equivalent to myVec = myVec.normalized * 5		
myVec.length = 5						
print(myVec)	
-> "Vector{3.0000,4.0000}"
```
##### Comparing
```lua
a = Vector(2,3)

-- only returns true if right hand side is a vector with equal components

a == 2
-> false
a == "test string"
-> false
a == {x = 2, y = 3}
-> false
a == Vector(2,3)						
-> true
a == Vector(3,2)
-> false

-- check if vector
Vector.isVector(a)						
-> true

-- no silly type coercion (ONLY IF FFI IS ENABLED)
Vector.isVector({x = 1, y = 2})			
-> false
```
##### String Directions
```lua
Vector.dir("up")
-> "Vector{0.0000,-1.0000}"

Vector.dir("top")
-> "Vector{0.0000,-1.0000}"

Vector.dir("down")
-> "Vector{0.0000,1.0000}"

Vector.dir("bottom")
-> "Vector{0.0000,1.0000}"

Vector.dir("left")
-> "Vector{-1.0000,0.0000}"

Vector.dir("right")
-> "Vector{1.0000,0.0000}"
```

##### Iterators
```lua
local pos = Vector(3,4)
for i,axis in Vector.axes("xy") do
	print(i, axis, pos[axis])
end
-> 1 x 3
-> 2 y 4

for i,axis in Vector.axes("yx") do
	print(i, axis, pos[axis])
end
-> 1 y 4
-> 2 x 3
```
