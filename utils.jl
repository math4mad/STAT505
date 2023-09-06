using MultivariateStats,CSV,DataFrames,RCall


function  make_fa(data)
    model=fit(FactorAnalysis,data;method=:em,maxoutdim=5)
    loadings(model)
end;#make_fa(data)


"""
    load_csv(str::AbstractString)
    load csv|>dataframe

"""
function load_csv(str::AbstractString)
    df = str |> d -> CSV.File("./data/$str.csv") |> DataFrame |> dropmissing
    return df
end


"""
    R_BartlettTest(data::Matrix,cormartrix::Matrix)
 
wrap  R's  Bartlett’s Test of Sphericity
  
>`h0:matrix is  an identity matrix`
  
>`ha:matrix is not an identity matrix`

ref:[R's  Bartlett’s Test of Sphericity](https://www.statology.org/bartletts-test-of-sphericity/)

## Arguments 
data:数据矩阵, cormartrix:协方差矩阵
## 返回值
Dict(:chisq,:p_value,:df)

"""
function R_BartlettTest(data::Matrix,cormartrix::Matrix)
            @rput data; @rput cormartrix
        R"""
            library(psych)
            res=cortest.bartlett(cormartrix, n = nrow(data))
        """
        res=@rget res
        return res
end

"""
R_KMOTest(data::Matrix)

use for factor analysis test

ref: [KMOTest](https://search.r-project.org/CRAN/refmans/EFAtools/html/KMO.html)
    
R's KMO test warp 

## Arguments

    data:  数据矩阵

## 返回值

   Dict(:MSA,:MSAi,:Image,:ImCov,:Call)

   关注::MSA  数值越接近于 1,说明适合做 Factor Analysis

"""
function R_KMOTest(data::Matrix)
    @rput data

    R"""
    library(psych)
    res= KMO(data)
    """
    return @rget res
end   


"""
    plot_eigenvals(ev::Vector{Float64}n=10;type::String="factor")
    
    plot  fa or pca's eigenvals
## Arguments
   
    1. ev: eigen array
    2. n: factor or pc  number
    3. type : "factor" || "pcs"

"""
function plot_eigenvals(ev::Vector{Float64},n=10;type::String="fa")
    xlabel=type=="fa" ? "factor" : "pcs"
    xs=1:n
    fig=Figure()
    ax=Axis(fig[1,1],xlabel=xlabel,ylabel="eigenvalue",xticks=xs)
    scatterlines!(ax,xs,ev[1:n];linewidth=4,msstyle...)
    hlines!(ax,[1],linewidth=3,color=:purple,linestyle=:dot)
    fig
end


"""
Stat505Table
struct for data load and description
"""
Base.@kwdef struct  Stat505Table
    page::Int
    name::AbstractString
    question:: AbstractString
    feature::Vector{Union{AbstractString,Symbol}}
end

msstyle=(marker=:circle,markersize=18,markercolor=(:red,0.6),strokewidth=0.5,strokecolor=:purple)