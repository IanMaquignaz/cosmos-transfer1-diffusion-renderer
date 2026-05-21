from cosmos_predict1.diffusion.inference.inference_inverse_renderer import parse_arguments, demo


if __name__ == "__main__":
    args = parse_arguments()
    demo(args)