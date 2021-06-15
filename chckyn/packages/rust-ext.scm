;; Adapted from https://github.com/nn1ks/dotfiles/blob/master/.config/guix/packages/rust-ext.scm
(define-module (chckyn packages rust-ext)
  ;; #:use-module (gnu packages base)
  ;; #:use-module (gnu packages compression)
  ;; #:use-module (gnu packages gcc)
  #:use-module (guix packages)
  #:use-module (guix download)
  ;; #:use-module (gnu packages rust) ;; Used for clippy package
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (nonguix build-system binary))

(define-public rust-src
  (package
    (name "rust-src")
    (version "1.52.1")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://static.rust-lang.org/dist/2021-05-10/rust-src-"
                            version ".tar.gz"))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256 (base32 "1gx87zpmbpcwa76c0v6d7i1g42fxg7qf2d79d3isrnxajiz43yrl"))))
    (build-system binary-build-system)
    (arguments
     `(#:install-plan
       `(("rust-src/lib" "./"))))
    (synopsis "Source for the Rust programming language")
    (description "Rust is a systems programming language that provides memory safety and thread safety guarantees.")
    (home-page "https://rust-lang.org")
    (license (list license:asl2.0 license:expat))))
