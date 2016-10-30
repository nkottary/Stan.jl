using Stan

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

  const simplecode = "
  data {real sigma;}
  parameters {real y;}
  model {y ~ normal(0,sigma);}
  "

  stanmodel = Stanmodel(Sample(save_warmup=true, thin=2), name="simple", model=simplecode);
  sim = stan(stanmodel, [Dict("sigma" => 1.)], CmdStanDir=CMDSTAN_HOME);
  describe(sim)
  
  isdir("tmp") &&
    rm("tmp", recursive=true);

end