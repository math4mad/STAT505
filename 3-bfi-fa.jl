"""
ref: https://www.datacamp.com/tutorial/introduction-factor-analysis
"""

include("utils.jl")
using CSV,DataFrames,GLMakie,MultivariateStats,RCall,Pipe,ScientificTypes,HypothesisTests
using RCall, StatsBase,LinearAlgebra,PrettyTables

#1.  load data 

    "排除不要的列"  
    desc=Stat505Table(0,"bfi","fa",["rownames","gender", "education", "age"])

    " `bfi` data->select|>coerce  to float64|>Matrix"
    df=@pipe load_csv(desc.name)|>select(_,Not(desc.feature))
    data=@pipe df|>coerce(_,Count=>Continuous)|>Matrix|>transpose
    cor_matrix=cor(data)
#2. BartlettTest
    
    #R_BartlettTest(data,cor_matrix)
        #= 
            :chisq   => 16484.8
            :p_value => 0.0
            :df      => 300.0
        =#
#3. KMO test  if  data suitable for FA
    #res=R_KMOTest(data)
    #res[:MSA]    #0.8469455121781345



#5. pre proceeding Factor Analysis for select factors

     julia_res=fit(FactorAnalysis,data;method=:cm,maxoutdim=6)
     
#5. R  fa  
    function R_FA()
        rdata=transpose(data)
        @rput rdata
        R"""
        library(psych)
        res=fa(rdata, nfactors=6,SMC=TRUE,fm-"ml",rotate="varimax")   
        """    
        res=@rget res
        return res 
    end
    #r_res=R_FA()
    #eval_arr=res[:e_values]
    
    #fig=plot_eigenvals(eval_arr);save("3-bfi-6fa-eigenval.png",fig)

#7.   data  PCA  analysis
       function step4()
            n_components=10
            M = fit(PCA, data; maxoutdim=n_components)
            pca_evs=eigvals(M)
            fig=plot_eigenvals(pca_evs,type="pca");
            return fig
       end
       #fig=step4()
# 8. R  loading
      #ma=res[:loadings]|>ma->round.(ma,digits=2)
      function show_loadings(loadings::Matrix)
            
            loading_df=DataFrame(loadings,:auto)
            #loading_df.feature=names(df)
    
            h1 = Highlighter(f= (data, i, j) -> (abs(data[i, j]) > 0.5),
                            crayon = crayon"red bold" )
            pretty_table(loading_df,tf = tf_compact, highlighters = (h1))
      end
    
      #show_loadings()
#9.  Julia Loadings   
      #ma=loadings(res)|>ma->round.(ma,digits=2)
      #show_loadings(ma)

#10.    loadings  heatmap
      #因为bif 的 feature 相关的都放在一起, 可以用 heatmap 可视化
      ma=R_FA()
      r_loadings=ma[:loadings]|>(d->abs.(d))|>(d->round.(d,digits=2))
      
      function plot_loading_hm(data::Matrix)
          fig=Figure(resolution=(600,800))
          ax=Axis(fig[1,1];xlabel="factor",ylabel="feature")
          ax.xticks=(1:6)
          ax.yticks=(1:25,reverse(names(df)))
          plt=heatmap!(ax,data';yflip=true)
          Colorbar(fig[1, 2],plt)
          fig
      end
      #fig=plot_loading_hm(r_loadings); save("./imgs/bfi-fa-loading-heatmap.png",fig)
 # 11. julia load  heatmap      
      jula_loadings=@pipe loadings(julia_res)|>abs.(_)|>round.(_,digits=2)
      
      function plot_loading_hm(data::Vector{Matrix{Float64}})
          fig=Figure(resolution=(1200,800))
          ax1=Axis(fig[1,1];xlabel="factor",ylabel="feature",title="R method")
          ax2=Axis(fig[1,2];xlabel="factor",ylabel="feature",title="Julia method")
          ax1.xticks=(1:6)
          ax1.yticks=(1:25,reverse(names(df)))
          ax2.xticks=(1:6)
          ax2.yticks=(1:25,reverse(names(df)))
          plt=heatmap!(ax1,data[1]';yflip=true)
          heatmap!(ax2,data[2]';yflip=true)
          Colorbar(fig[1, 3],plt)
          fig
       end

       fig=plot_loading_hm([r_loadings,jula_loadings]);save("./imgs/bfi-fa(r-julia(cm)-compare)-heatmap.png",fig)