# Chapter 8. WIP
defmodule Schemer.LambdaTheUltimate do
  import Schemer.Shadows, only: [
    operator_for: 1,
    first_sub_expression: 1,
    second_sub_expression: 1
  ]

  import Schemer.FullOfStars, only: [equal: 2]

  @moduledoc """
  The Ninth Commandment: Abstract common patterns with a new function.
  @wip p. 150

  multiremberT
  multirember&co
  multiinsertLR
  multiinsertLR&co
  evens-only*
  evens-only&co
  """

  @doc """
  (define rember-f
    (lambda (test? a l)
     (cond
       ((null? l) '())
       ((test? (car l) a)
        (cdr l))
       (else
         (cons (car l)
           (rember-f test? a (cdr l)))))))

  (rember-f = 5 '(6 2 5 3))
  => (6 2 3)

  (rember-f eq? 'jelly '(jelly beans are good))
  => (beans are good)

  (rember-f equal? '(pop corn) '(lemonade (pop corn) and (cake)))
  => (lemonde and (cake))
  """
  def rember_f(_, _, []), do: []
  def rember_f(f, a, [h|t]) do
    case f.(a, h) do
      true  -> t
      false -> [h | rember_f(f, a, t)]
    end
  end

  @doc """
  (define eq?-c
    (lambda (a)
      (lambda (x)
        (eq? x a))))

  (define eq?-salad (eq?-c 'salad))
  """
  def eq_c(a), do: fn (x) -> a == x end

  def eq_salad, do: eq_c(:salad)

  @doc """
  (define rember-f-curry
    (lambda (test?)
      (lambda (a l)
        (cond
          ((null? l) '())
          ((test? (car l) a)
            (cdr l))
          (else
            (cons (car l)
              ((rember-f-curry test?) a (cdr l))))))))
  """
  def rember_f_curry(test_fn) do
    fn (_, [])    -> []
       (a, [h|t]) ->
         case test_fn.(a, h) do
           true  -> t
           false -> [h | rember_f_curry(test_fn).(a, t)]
         end
    end
  end

  @doc """
  (define insertL-f
    (lambda (test?)
      (lambda (n o l)
        (cond
          ((null? l) '())
          ((test? (car l) o)
           (cons n l))
          (else
            (cons (car l)
              ((insertL-f test?) n o (cdr l))))))))

  ((insertL-f eq?) 'a 'c '(c d c))
  => (a c d c)
  """
  def insertL_f(test_fn) do
    fn (_, _, []) -> []
       (n, o, [h|t] = l) ->
         case test_fn.(o, h) do
           true  -> [n | l]
           false -> [h | insertL_f(test_fn).(n, o, t)]
         end
    end
  end

  @doc """
  (define insertR-f
    (lambda (test?)
      (lambda (n o l)
        (cond
          ((null? l) '())
          ((test? (car l) o)
           (cons o (cons n (cdr l))))
          (else
            (cons (car l)
                  ((insertR-f test?) n o (cdr l))))))))

  ((insertR-f eq?) 'c 'a '(a d c))
  => (a c d c)
  """
  def insertR_f(test_fn) do
    fn (_, _, []) -> []
       (n, o, [h|t]) ->
         case test_fn.(o, h) do
           true  -> [o | [n | t]]
           false -> [h | insertR_f(test_fn).(n, o, t)]
         end
    end
  end

  @doc """
  (define seqL
    (lambda (n o l)
      (cons n (cons o l))))

  (define seqR
    (lambda (n o l)
      (cons o (cons n l))))

  (define insert-g
    (lambda (insert-strategy)
      (lambda (n o l)
        (cond
          ((null? l) '())
          ((eq? (car l) o)
           (insert-strategy n o (cdr l)))
          (else
            (cons (car l)
              ((insert-g insert-strategy) n o (cdr l))))))))

  ((insert-g seqR) 'c 'a '(a d c))
  ((insert-g seqL) 'a 'c '(c d c))
  """
  def seqL(n, o, l), do: [n | [o | l]]
  def seqR(n, o, l), do: [o | [n | l]]

  def insert_g(insert_strategy) do
    fn (_, _, [])    -> []
       (n, o, [o|t]) -> insert_strategy.(n, o, t)
       (n, o, [h|t]) -> [h | insert_g(insert_strategy).(n, o, t)]
    end
  end

  @doc """
  (define seqS (lambda (n o l) (cons n l)))
  (define subst (insert-g seqS))

  (subst 'elixir 'erlang '(my other erlang is an elixir))
  => (my other elixir is an erlang)
  """
  def seqS(n, _, l), do: [n | l]
  def subst(n, o, l), do: insert_g(&seqS/3).(n, o, l)

  @doc """
  (define seqrem (lambda (n o l) l))

  (define rember
    (lambda (n l)
      ((insert-g seqrem) #f n l))))

  (rember 'worm '(apple apple worm apple))
  => '(apple apple apple)
  """
  def seqrem(_, _, l), do: l
  def rember(a, l), do: insert_g(&seqrem/3).(nil, a, l)

  @doc """
  (define atom-to-function
    (lambda (x)
      (cond
        ((eq? x '*) *)
        ((eq? x '+) +)
         (else ^))))

  (define value
    (lambda (nexp)
      (cond
        ((atom? nexp) nexp)
        (else
          ((atom-to-function (operator nexp))
           (value (1st-sub-expression nexp))
           (value (2nd-sub-expression nexp)))))))

  (value '(1 + (3 * 4)))
  => 13
  """
  def atom_to_function(:+), do: &add/2
  def atom_to_function(:*), do: &times/2
  def atom_to_function(:^), do: &pow/2

  def value([_|_]=nexp) do
    atom_to_function(operator_for(nexp)).(
      value(first_sub_expression(nexp)),
      value(second_sub_expression(nexp))
    )
  end
  def value(nexp), do: nexp

  defp pow(_, 0), do: 1
  defp pow(n, m), do: n * pow(n, m-1)

  defp add(n, m), do: n + m

  defp times(n, m), do: n * m

  @doc """
  (define multirember-f
    (lambda (test?)
      (lambda (a l)
        (cond
          ((null? l) (quote ()))
          ((test? (car l) a)
           ((multirember-f test?) a (cdr l)))
          (else
            (cons (car l)
              ((multirember-f test?) a (cdr l))))))))

  ((multirember-f eq?) (quote c) (quote (a c d c)))
  => (a d)
  """
  def multirember_f(test) do
    fn (_, [])    -> []
       (a, [h|t]) ->
         case test.(a, h) do
           true   -> multirember_f(test).(a, t)
           false  -> [h | multirember_f(test).(a, t)]
         end
    end
  end

  @doc """
  (define multirember-eq? (multirember-f eq?))
  """
  def multirember_eq, do: multirember_f(&equal/2)

  @doc """
  (define eq?-tuna
    (eq?-c (quote tuna)))

  (define multiremberT
    (lambda (test)
      (lambda (l)
        (cond
          ((null? l) (quote ()))
          ((test (car l))
            ((multiremberT test) (cdr l)))
          (else
            (cons (car l)
              ((multiremberT test) (cdr l))))))))

  ((multiremberT eq?-tuna) (quote (shrimp salad tuna salad and tuna)))
  => (shrimp salad salad and)
  """
  def eq_tuna, do: eq_c(:tuna)

  def multiremberT(test) do
    fn ([])    -> []
       ([h|t]) ->
         case test.(h) do
           true  -> multiremberT(test).(t)
           false -> [h | multiremberT(test).(t)]
         end
    end
  end
end
