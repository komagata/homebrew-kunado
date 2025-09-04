class Kunado < Formula
  desc "Rails development gateway for HTTPS access to multiple apps"
  homepage "https://github.com/komagata/kunado"
  url "https://github.com/komagata/kunado/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "904e45254b10908c3a2e933e9ddd0a2801a24ba630e88c8f561c8214e92b357b"
  license "MIT"

  depends_on "docker"
  depends_on "ruby"

  def install
    bin.install "kunado"
    
    # Create necessary directories
    (var/"kunado").mkpath
    (var/"kunado/routes").mkpath
    (var/"kunado/certs").mkpath
    
    # Only create registry.json if it doesn't exist
    registry_file = var/"kunado/registry.json"
    registry_file.write("{}") unless registry_file.exist?
  end

  service do
    run [opt_bin/"kunado", "proxy", "up"]
    run_type :immediate
    keep_alive true
    log_path var/"log/kunado.log"
    error_log_path var/"log/kunado.error.log"
    environment_variables PATH: std_service_path_env, KUNADO_SERVICE: "true"
  end

  def post_install
    ohai "Setting up Kunado..."
    
    # Try to start proxy to generate certificates
    system "#{bin}/kunado", "proxy", "up" rescue nil
    sleep 1
    system "#{bin}/kunado", "proxy", "down" rescue nil
    
    ohai ""
    ohai "🚀 Quick Start:"
    ohai "  brew services start kunado    # Start with auto-start"
    ohai "  echo 'eval \"$(kunado hook)\"' >> ~/.zshrc"
    ohai ""
    ohai "Then in your Rails app:"
    ohai "  kunado add"
    ohai "  rails s"
  end
  
  def caveats
    <<~EOS
      Kunado will request your password once to install its certificate.
      This is only needed the first time you run 'kunado proxy up'.
      
      The certificate enables HTTPS without browser warnings.
    EOS
  end

  test do
    assert_match "kunado #{version}", shell_output("#{bin}/kunado version")
  end
end