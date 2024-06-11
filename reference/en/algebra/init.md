## Copy
`(Copy obj)`, *procedure*

Makes a deep copy of array. Do not change the type of array.
```scheme
> (Copy [1 2 3])
[1 2 3]
```

## Copy~
`(Copy~ obj)`, *procedure*

Makes a deep copy of array. Changes type of array to the *native*.
```scheme
> (Copy~ [1 2 3])
[1.0 2.0 3.0]
```
