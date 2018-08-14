class Bazel < Formula
  desc 'Bazel is a fast, scalable, multi-language and extensible build system'
  homepage 'https://bazel.build/'
  version '0.16.1'
  url "https://releases.bazel.build/#{version}/release/bazel-#{version}-installer-darwin-x86_64.sh", using: :nounzip
  sha256 '07d5c753738c7186117168770f525b59c39b24103f714be2ffcaadd8e2c53a78'

  bottle :unneeded

  def install
    system 'chmod', '0555', "./bazel-#{version}-installer-darwin-x86_64.sh"
    system "./bazel-#{version}-installer-darwin-x86_64.sh", "--prefix=#{buildpath}"

    bin.install 'lib/bazel/bin/bazel' => 'bazel'
    bin.install 'lib/bazel/bin/bazel-real' => 'bazel-real'
    bin.env_script_all_files(libexec / 'bin', Language::Java.overridable_java_home_env)

    bash_completion.install 'lib/bazel/bin/bazel-complete.bash'
  end

  test do
    touch testpath / 'WORKSPACE'

    (testpath / 'ProjectRunner.java').write <<~EOS
      public class ProjectRunner {
        public static void main(String args[]) {
          System.out.println("Hi!");
        }
      }
    EOS

    (testpath / 'BUILD').write <<~EOS
      java_binary(
        name = "bazel-test",
        srcs = glob(["*.java"]),
        main_class = "ProjectRunner",
      )
    EOS

    system bin / 'bazel', 'build', '//:bazel-test'
    system 'bazel-bin/bazel-test'
  end
end
