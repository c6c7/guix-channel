(define-module (chckyn packages tree-sitter)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu))

(define-public tree-sitter
  (package
    (name "tree-sitter")
    (version "v0.19.4")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/tree-sitter/tree-sitter")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
                (base32 "1375ksjz2iysk9rh365z60n3f8ziqk41r8jdxjwsv9dsnd71nd3n"))))
    (build-system gnu-build-system)
    (arguments
      '(#:phases (modify-phases %standard-phases
                   (delete 'configure)
                   (delete 'check)
                   (add-before 'build 'set-prefix-in-makefile
                    (lambda* (#:key outputs #:allow-other-keys)
                      ;; Modify the makefile so that its
                      ;; 'PREFIX' variable points to "out".
                      (let ((out (assoc-ref outputs "out")))
                        (substitute* "Makefile"
                          (("PREFIX \\?=.*")
                           (string-append "PREFIX = " out "\n")))
                        #true))))
        #:make-flags '("CC=gcc")))
    (home-page "https://tree-sitter.github.io/")
    (synopsis "Tree-sitter is a parser generator tool and an incremental parsing library.")
    (description "Tree-sitter is a parser generator tool and an incremental parsing library. It can build a concrete syntax tree for a source file and efficiently update the syntax tree as the source file is edited. Tree-sitter aims to be:

@itemize
@item General enough to parse any programming language
@item Fast enough to parse on every keystroke in a text editor
@item Robust enough to provide useful results even in the presence of syntax errors
@item Dependency-free so that the runtime library (which is written in pure C) can be embedded in any application
@end itemize\n")
    (license #f)))
