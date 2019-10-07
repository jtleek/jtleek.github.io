x = rnorm(100)
z = rnorm(100, mean = 2, sd = 0.5)
y = 2 + 2*x + x^2

df = data.frame(y,x,z)

## I want to fit linear model y ~ x + z 
lm(y ~ x + z, df)

## fit linear model on nested data set. 
df_nest = tidyr::nest(df, x, z) ## nest x, z into one column named data

lm(y ~ data, df_nest) ## cannot fit linear model y ~ data
