using Distributed
using Dates
@everywhere using Serialization
@everywhere using DelimitedFiles
@everywhere using JLD2

const jobs = RemoteChannel(()->Channel{Tuple}(32))
const res = RemoteChannel(()->Channel{Tuple}(32))

# count the number of jobs
num = 0
function make_jobs(ns::Array{Int, 1}, σs::Array{Int, 1})
    for n in ns
        for σ in σs
            put!(jobs, (n, σ))
        end
    end
    global num = length(ns) * length(σs)
end

@everywhere function do_work(jobs, res, folder, resfolder, nrep; adaptive = false)
    while true
        n, σ = take!(jobs)
        exec_time = @elapsed begin
            # no sampling rate
            @load folder * "/$(nrep)_XM_$(n)_$(σ).jld2" X M
            acc = cum_run_KTHSE(X, M, σ = 1.0*σ)
        end
        writedlm("$(resfolder)/$(nrep)_exectime_$(n)_$(σ).txt", exec_time)
        writedlm("$(resfolder)/$(nrep)_acc_$(n)_$(σ).txt", acc)
        put!(res, ("$(n)_$(σ)", exec_time, myid()))
    end
end

# main function
nrep, parent_folder, folder = ARGS
@async make_jobs(collect(15:5:50),
                 collect(1:4))
# timestamp = Dates.now()
# folder = "data_$(nf)_$(nr)_$(zoom)_$(timestamp)"
# mkdir(folder)

for p in workers()
    remote_do(do_work, p, jobs, res, parent_folder, folder, nrep; adaptive = true)
end

while num > 0
    job_id, exec_time, where = take!(res)
    println("$job_id finished in $(round(exec_time; digits=2)) secs on worker $where")
    global num -= 1
end