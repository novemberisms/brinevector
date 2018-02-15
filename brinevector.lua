--[[
BrineVector: a luajit ffi-accelerated vector library

Copyright 2018 Brian Sarfati

Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
and associated documentation files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or 
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE 
AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local ffi = require "ffi"
ffi.cdef[[
typedef struct {
  float x;
  float y;
} brinevector;
]]

local Vector = {}
setmetatable(Vector,Vector)


function Vector.__index(t, k)
  if k == "length" then 
    return Vector.getLength(t) 
  elseif k == "normalized" then
    return Vector.getNormalized(t)
  elseif k == "angle" then
    return Vector.getAngle(t)
  elseif k == "length2" then
    return Vector.getLengthSquared(t)
  end
  return rawget(Vector,k)
end

function Vector.getLength(v)
  return math.sqrt(v.x * v.x + v.y * v.y)
end

function Vector.getLengthSquared(v)
  return v.x*v.x + v.y*v.y
end

function Vector.getNormalized(v)
  local length = v.length
  if length == 0 then return Vector(0,0) end
  return Vector(v.x / length, v.y / length)
end

function Vector.getAngle(v)
  return math.atan2(v.y, v.x)
end

function Vector.__newindex(t,k,v)
  if k == "length" then
    local res = t.normalized * v
    t.x = res.x
    t.y = res.y
    return
  end
  if k == "angle" then
    local res = t:angled(v)
    t.x = res.x
    t.y = res.y
    return
  end
  if type(t) == "cdata" then
    error("Cannot assign a new property '" .. k .. "' to a Vector") 
  else
    rawset(t,k,v)
  end
end

function Vector.angled(v, angle)
  local length = v.length
  return Vector(math.cos(angle) * length, math.sin(angle) * length)
end

function Vector.trim(v,mag)
  if v.length < mag then return v end
  return v.normalized * mag
end

function Vector.split(v)
  return v.x, v.y
end

function Vector.hadamard(v1, v2) -- also known as "Componentwise multiplication"
  return Vector(v1.x * v2.x, v1.y * v2.y)
end

local iteraxes_lookup = {
  xy = {"x","y"},
  yx = {"y","x"}
}
local function iteraxes(ordertable, i)
  i = i + 1
  if i > 2 then return nil end
  return i, ordertable[i]
end

function Vector.axes(order)
  return iteraxes, iteraxes_lookup[order or "yx"], 0
end

function Vector.isVector(arg)
  return ffi.istype("brinevector",arg)
end

function Vector.__add(v1, v2)
  return Vector(v1.x + v2.x, v1.y + v2.y)
end

function Vector.__sub(v1, v2)
  return Vector(v1.x - v2.x, v1.y - v2.y)
end

function Vector.__mul(v1, op)
  -- acts as a dot multiplication if op is a vector
  -- if op is a scalar then works as usual
  if type(v1) == "number" then
    return Vector(op.x * v1, op.y * v1)
  end
  if type(op) == "cdata" then
    return v1.x * op.x + v1.y * op.y
  else
    return Vector(v1.x * op, v1.y * op)
  end
end

function Vector.__div(v1, op)
  if type(op) ~= "number" then error("must divide by a scalar") end
  return Vector(v1.x / op, v1.y / op)
end

function Vector.__unm(v)
  return Vector(-v.x, -v.y)
end

function Vector.__eq(v1,v2)
  if (not ffi.istype("brinevector",v2)) or (not ffi.istype("brinevector",v1)) then return false end
  return v1.x == v2.x and v1.y == v2.y
end

function Vector.__mod(v1,v2)  -- ran out of symbols, so i chose % for the hadamard product
  return Vector(v1.x * v2.x, v1.y * v2.y) 
end

function Vector.__tostring(t)
  return string.format("Vector{%.4f,%.4f}",t.x,t.y)
end

function Vector.__call(t,x,y)
  return ffi.new("brinevector",x or 0,y or 0)
end

ffi.metatype("brinevector",Vector)

return Vector