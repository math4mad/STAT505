include("utils.jl")
using CSV,DataFrames,GLMakie,MultivariateStats,RCall
str="sales"
data=load_csv(str)|>Matrix|>transpose

make_fa(data)