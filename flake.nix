{
  description = "A collection of flake templates";

  outputs = { self }: {
    templates = {
      python-cuda = {
        path = ./python-cuda;
        description = "Python environment with CUDA";
      };
      python-cuda12 = {
        path = ./python-cuda12;
        description = "Python environment with CUDA 12";
      };

    };

  };
}
