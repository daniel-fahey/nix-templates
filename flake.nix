{
  description = "A collection of flake templates";

  outputs = { self }: {
    templates = {
      python-cuda = {
        path = ./python-cuda;
        description = "Python environment with CUDA";
      };

    };

  };
}
