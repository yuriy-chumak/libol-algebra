## Copy
`(Copy obj)`, *procedure*

Makes a deep copy of an obj. Do not change the type of array.
```scheme
> (Copy [1 2 3])
#(1 2 3)
```

## Copy~
`(Copy~ obj)`, *procedure*

Makes a deep copy of an obj. Changes type of array to the fast.
```scheme
> (Copy~ [1 2 3])
[1.0 2.0 3.0]
```
