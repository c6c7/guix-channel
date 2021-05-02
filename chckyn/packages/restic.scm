(define-module (chckyn packages restic)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system go)
  #:use-module (gnu packages python)
  #:use-module (gnu packages version-control))

(define-public restic
  (package
    (name "restic")
    (version "0.12.0")
    ;; TODO Try packaging the bundled / vendored dependencies in the 'vendor/'
    ;; directory.
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/chckyn/restic")
		     (commit (string-append "v" version "_vendor"))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "12xciygmq2zyfw230bl9ndcygrnsbxzcvn8sqf92kg74984yv37s"))))
    (build-system go-build-system)
    (native-inputs
     `(("python" ,python)
       ("git" ,git)))
    (arguments
     `(#:import-path "github.com/restic/restic"
      ;; We don't need to install the source code for end-user applications.
       #:install-source? #f
       #:phases
       (modify-phases %standard-phases
         (replace 'build
           (lambda* (#:key inputs #:allow-other-keys)
             (with-directory-excursion "src/github.com/restic/restic"
               ;; Disable 'restic self-update'.  It makes little sense in Guix.
               (substitute* "build.go" (("selfupdate") ""))
               (setenv "HOME" (getcwd)) ; for $HOME/.cache/go-build
               (invoke "make"))))

         (replace 'check
           (lambda _
             (with-directory-excursion "src/github.com/restic/restic"
               ;; Disable FUSE tests.
               (setenv "RESTIC_TEST_FUSE" "0")
               (invoke "make" "test"))))

         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out"))
                   (src "src/github.com/restic/restic"))
               (install-file (string-append src "/restic")
                             (string-append out "/bin"))
               #t)))

         (add-after 'install 'install-docs
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (man "/share/man")
                    (man-section (string-append man "/man"))
                    (src "src/github.com/restic/restic/doc/man/"))
               ;; Install all the man pages to "out".
               (for-each
                 (lambda (file)
                   (install-file file
                                 (string-append out man-section
                                                (string-take-right file 1))))
                 (find-files src "\\.[1-9]"))
               #t)))

         (add-after 'install-docs 'install-shell-completion
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (bin (string-append out "/bin"))
                    (etc (string-append out "/etc"))
                    (share (string-append out "/share")))
               (for-each
                (lambda (shell)
                  (let* ((shell-name (symbol->string shell))
                         (dir (string-append "etc/completion/" shell-name)))
                    (mkdir-p dir)
                    (invoke (string-append bin "/restic") "generate"
                            (string-append "--" shell-name "-completion")
                            (string-append dir "/"
                                           (case shell
                                             ((bash) "restic")
                                             ((zsh) "_restic"))))))
                '(bash zsh))
               (with-directory-excursion "etc/completion"
                 (install-file "bash/restic"
                               (string-append etc "/bash_completion.d"))
                 (install-file "zsh/_restic"
                               (string-append share "/zsh/site-functions")))
               #t))))))
    (home-page "https://restic.net/")
    (synopsis "Backup program with multiple revisions, encryption and more")
    (description "Restic is a program that does backups right and was designed
with the following principles in mind:

@itemize
@item Easy: Doing backups should be a frictionless process, otherwise you
might be tempted to skip it.  Restic should be easy to configure and use, so
that, in the event of a data loss, you can just restore it.  Likewise,
restoring data should not be complicated.

@item Fast: Backing up your data with restic should only be limited by your
network or hard disk bandwidth so that you can backup your files every day.
Nobody does backups if it takes too much time.  Restoring backups should only
transfer data that is needed for the files that are to be restored, so that
this process is also fast.

@item Verifiable: Much more important than backup is restore, so restic
enables you to easily verify that all data can be restored.  @item Secure:
Restic uses cryptography to guarantee confidentiality and integrity of your
data.  The location the backup data is stored is assumed not to be a trusted
environment (e.g.  a shared space where others like system administrators are
able to access your backups).  Restic is built to secure your data against
such attackers.

@item Efficient: With the growth of data, additional snapshots should only
take the storage of the actual increment.  Even more, duplicate data should be
de-duplicated before it is actually written to the storage back end to save
precious backup space.
@end itemize")
    (license license:bsd-2)))
