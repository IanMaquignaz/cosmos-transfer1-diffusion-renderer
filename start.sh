# THIS IS THE COMMAND TO RUN THE INFERENCE SCRIPT on TRILLIUM
# CUDA_VISIBLE_DEVICES=0 python main.py \
#     --checkpoint_dir checkpoints --diffusion_transformer_dir Diffusion_Renderer_Inverse_Cosmos_7B \
#     --dataset_path=asset/examples/image_examples/ --num_video_frames 1 --group_mode webdataset \
#     --video_save_folder=asset/example_results/image_delighting/ --save_video=False

for dir in samples/* ; do
    echo "Entering: $dir"

    CUDA_VISIBLE_DEVICES=0 python main.py \
    --checkpoint_dir checkpoints --diffusion_transformer_dir Diffusion_Renderer_Inverse_Cosmos_7B \
    --dataset_path=$dir --num_video_frames 1 --group_mode webdataset \
    --video_save_folder=$dir/image_delighting/ --save_video=False
done

# # TEST ENVIRONMENT
# module load StdEnv/2023 gcc cuda/12.2 cudacore/.12.2.2 cudnn/9.2.1.18 python/3.11 arrow/24 opencv/4.13
# virtualenv --clear ENV_COSMOS && source ENV_COSMOS/bin/activate
# # pip install --no-index --upgrade pip
# # pip install --no-index transformer-engine[pytorch]==1.12.0 numpy
# # python -c 'import transformer_engine.common'
# ls $CUDA_HOME/lib/libnvrtc.so
# ls /cvmfs/soft.computecanada.ca/easybuild/software/2023/x86-64-v3/CUDA/cuda12.9/cudnn/9.13.1.26/lib/libcudnn_engines_runtime_compiled.so.9


# # # STEPS TO BUILD THE ACTUAL ENVIRONMENT
# .drac/build_env.sh
# .drac/export_env_modules.sh
# . .drac/export_env_modules.sh && module load $ENV_COSMOS_MODULES && source ENV_COSMOS/bin/activate