######### Stan program example  ###########

using Mamba, Stan, Compat

old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "Bernoulli")
cd(ProjDir)

bernoulli = "
data { 
  int<lower=0> N; 
  int<lower=0,upper=1> y[N];
} 
parameters {
  real<lower=0,upper=1> theta;
} 
model {
  theta ~ beta(1,1);
    y ~ bernoulli(theta);
}
"

bernoullidata = [
  @Compat.Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]),
  @Compat.Dict("N" => 10, "y" => [0, 1, 0, 0, 0, 0, 1, 0, 0, 1]),
  @Compat.Dict("N" => 10, "y" => [0, 0, 0, 0, 0, 0, 1, 0, 1, 1]),
  @Compat.Dict("N" => 10, "y" => [0, 0, 0, 1, 0, 0, 0, 1, 0, 1])
]

stanmodel = Stanmodel(Variational(), name="bernoulli", model=bernoulli);

sim1 = stan(stanmodel, bernoullidata, ProjDir, CmdStanDir=CMDSTAN_HOME);
monitor = ["theta"]
sim = sim1[1:size(sim1, 1), monitor, 1:size(sim1, 3)]
Mamba.describe(sim)
println()

## Plotting
p = plot(sim, [:trace, :mean, :density, :autocor], legend=true);
draw(p, ncol=4, filename="$(stanmodel.name)-summaryplot", fmt=:svg)
draw(p, ncol=4, filename="$(stanmodel.name)-summaryplot", fmt=:pdf)

# Below will only work on OSX, please adjust for your environment.
# JULIA_SVG_BROWSER is set from environment variable JULIA_SVG_BROWSER
@osx ? if isdefined(Main, :JULIA_SVG_BROWSER) && length(JULIA_SVG_BROWSER) > 0
        for i in 1:4
          isfile("$(stanmodel.name)-summaryplot-$(i).svg") &&
            run(`open -a $(JULIA_SVG_BROWSER) "$(stanmodel.name)-summaryplot-$(i).svg"`)
        end
      end : println()

cd(old)
