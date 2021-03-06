; leaf
(define (make-leaf symbol weight)
  (list 'leaf symbol weight))
(define (leaf? object)
  (eq? (car object) 'leaf))
(define (symbol-leaf leaf)
  (cadr leaf))
(define (weight-leaf leaf)
  (caddr leaf))

; code tree
(define (make-code-tree left right)
  (list left
        right
        (append (symbols left) (symbols right))
        (+ (weight left) (weight right))))
(define (left-branch tree) (car tree))
(define (right-branch tree) (cadr tree))
(define (symbols tree)
  (if (leaf? tree)
      (list (symbol-leaf tree))
      (caddr tree)))
(define (weight tree)
  (if (leaf? tree)
      (weight-leaf tree)
      (cadddr tree)))

; decode
; bits is a list of 1s and 0s
(define (decode bits tree)
  (define (decode-1 bits current-branch) ;定义一个辅助函数的作用是为了保存完整的encode tree，当解码完一个字符后，再从encode tree的根节点开始解码下一个字符
    (if (null? bits)
        '()
        (let ((next-branch (choose-branch (car bits) current-branch)))
          (if (leaf? next-branch)
              (cons (symbol-leaf next-branch) 
                    (decode-1 (cdr bits) tree))
              (decode-1 (cdr bits) next-branch)))))
  (decode-1 bits tree))
(define (choose-branch bit tree)
  (cond ((= bit 0) (left-branch tree))
        ((= bit 1) (right-branch tree))
        (else (error "bad bit: CHOOSE-BRANCH" bit))))

; generate code tree
(define (generate-huffman-tree pairs)
  (successive-merge (make-leaf-set pairs)))

(define (successive-merge trees)
   (if (eq? '() (cddr trees)) ;只有最后两个要合并的树了
       (make-code-tree (car trees) (cadr trees))
       (successive-merge (adjoin-set
                           (make-code-tree (car trees) (cadr trees))
                           (cddr trees)))))
; x is a tree, set is a set of trees arranged in incresing order of weight
(define (adjoin-set x set)
  (cond ((null? set) (list x))
        ((< (weight x) (weight (car set))) (cons x set))
        (else (cons (car set)
                    (adjoin-set x (cdr set))))))
; 把pairs转成权重递增的leaf
(define (make-leaf-set pairs)
  (if (null? pairs)
      '()
      (let ((pair (car pairs)))
        (adjoin-set (make-leaf (car pair) (cdr pair)) ;这个方法用map把pair转成leaf后再做排序代码更清晰
                    (make-leaf-set (cdr pairs))))))

; encode
(define (encode message tree)
  (if (null? message)
      '()
      (append (encode-symbol (car message) tree)
              (encode (cdr message) tree))))
(define (encode-symbol symbol tree)
  (if (leaf? tree)
      (if (eq? symbol (symbol-leaf tree))
          '()
          (error "symbol is not in this encoding tree" symbol))
      (cond ((in-tree? symbol (left-branch tree))
             (cons 0 (encode-symbol symbol (left-branch tree))))
            ((in-tree? symbol (right-branch tree))
             (cons 1 (encode-symbol symbol (right-branch tree))))
            (else (error "symbol is not in this encoding tree" symbol)))))

(define (in-tree? symbol tree)
  (if (leaf? tree)
      (eq? symbol (symbol-leaf tree))
      (if (eq? (memq symbol (symbols tree)) #f)
          #f
          #t)))

; define a tree
(define sample-tree
  (make-code-tree (make-leaf 'A 4)
                  (make-code-tree (make-leaf 'B 2)
                                  (make-code-tree (make-leaf 'D 1)
                                                  (make-leaf 'C 1)))))

; define a coded message
(define sample-message '(0 1 1 0 0 1 0 1 0 1 1 1 0))

; define a message
(define origin-message '(a d a b b c a))

; define pairs
(define sample-pairs (list (cons 'a 4) (cons 'b 2) (cons 'd 1) (cons 'c 1)))
