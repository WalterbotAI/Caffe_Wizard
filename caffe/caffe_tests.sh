echo 100> /sys/devices/system/cpu/intel_pstate/min_perf_pct
echo 0> /sys/devices/system/cpu/intel_pstate/no_turbo
cpupower frequency-set -g performance
export OMP_NUM_THREADS=64
export KMP_AFFINITY="verbose,none"
export MIC_KMP_AFFINITY="verbose,none"
##############################################################

./build/tools/caffe train --solver=models/intel_optimized_model/multinode/alexnet_4nodes/solver.prototxt --engine=MKL2017 2>&1 | tee train_alexnet_1nodes_0409_omp_set_64.log
./build/tools/caffe time --model models/intel_optimized_models/multinode/alexnet_4nodes/train_val.prototxt --engine=MKL2017 2>&1 | tee TESTING_alexnet_1nodes_100it.log


#./build/tools/caffe train --solver=models/intel_optimized_models/multinode/googlenet_4nodes/solver.prototxt --engine=MKL2017 2>&1 | tee train_googlenet_v2_1nodes_0409_omp_set_64.log
#./build/tools/caffe time --model models/intel_optimized_models/multinode/googlenet_4nodes/train_val.prototxt --engine=MKL2017 2>&1 | tee TESTING_googlenet_4nodes_100it.log

./build/tools/caffe train --solver=models/intel_optimized_models/multinode/resnet_50_16_nodes/solver.prototxt --engine=MKL2017 2>&1 | tee train_resnet_50_1nodes_0409_omp_set_64.log
./build/tools/caffe time --model models/intel_optimized_models/multinode/resnet_50_16_nodes/train_val.prototxt --engine=MKL2017 2>&1 | tee TESTING_resnet_50_16_100it.log


#./build/tools/caffe train --solver=models/default_vgg_16/solver.prototxt --engine=MKL2017 2>&1 | tee train_vgg16_1nodes_0409_omp_set_64.log

#./build/tools/caffe train --solver=models/default_vgg_19/solver.prototxt --engine=MKL2017 2>&1 | tee train_vgg19_1nodes_0409_omp_set_64.log


