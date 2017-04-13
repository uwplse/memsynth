#lang racket

(require racket/runtime-path net/url file/unzip)
(provide setup-alloy compile-java)


(define-runtime-path bin ".")


(define urls
  (hash "alloy4.2_2015-02-22.jar" "http://alloy.mit.edu/alloy/downloads/alloy4.2_2015-02-22.jar"
        "hola-0.2.jar" "http://alloy.mit.edu/alloy/hola/downloads/hola-0.2.jar"))


(define (setup-alloy [jar "hola-0.2.jar"])
  (define alloy.jar (build-path bin jar))
  (unless (file-exists? alloy.jar)
    (unless (hash-has-key? urls jar)
      (error 'setup-alloy "unknown alloy jar ~v" jar))
    (printf "Downloading ~v...\n" jar)
    (define download (get-pure-port (string->url (hash-ref urls jar))))
    (call-with-output-file alloy.jar (lambda (out) (copy-port download out))))
  (define alloy-dir (path-replace-extension alloy.jar ""))
  (unless (directory-exists? alloy-dir)
    (call-with-unzip
     alloy.jar
     (lambda (p) (copy-directory/files p alloy-dir))))
  (values alloy.jar
          (match (system-type)
            ['unix (build-path alloy-dir "amd64-linux")]
            ['macosx (build-path alloy-dir "x86-mac")])))


(define (compile-java file [jar "hola-0.2.jar"])
  (define alloy.jar (build-path bin jar))
  (define ret (system (format "javac -cp ~a ~a" 
                              (resolve-path alloy.jar)
                              (resolve-path (build-path bin file)))))
  (unless ret
    (error 'compile-java "javac failed")))
