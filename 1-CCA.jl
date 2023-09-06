
import MultivariateStats:projection,predict
using MultivariateStats, CSV,DataFrames,MLJ

df=CSV.File("./data/sales.csv")|>DataFrame|>d->coerce(d,Count=>Continuous)


first(df,10)

#X,Y  列为观测数据
tma=(df)|>Matrix|>transpose
X,Y=tma[1:3,:],tma[4:7,:]


M=fit(CCA, X, Y;method=:svd)

predict(M,Y)