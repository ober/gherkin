;; Test that errors don't halt script execution
(##nonexistent-primitive)
(displayln "after-error")
