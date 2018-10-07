require 'benchmark'
require 'narray'
require 'numo/gnuplot'
require 'numo/narray'
require 'cumo/narray'
require 'pycall/import'
require './array'

using UsuiHon
dir = "./results"

class ArrayBenchmark
  include PyCall::Import
  def initialize
    pyimport 'numpy', as: :np
  end

  class << self
    def sec(type, sizes: (0..4).map{|n| 10 ** n }, iterations: 100, default: 13)
      benchmarks = Benchmark.benchmark type.to_s do |bm|
        sizes.each do |size|
          array = new.eval_array(type, size, default)
          bm.report("#{type}#+#{size}") { iterations.times { array + 3 } }
          bm.report("#{type}#-#{size}") { iterations.times { array - 3 } }
          bm.report("#{type}#*#{size}") { iterations.times { array * 3 } }
          bm.report("#{type}#/#{size}") { iterations.times { array / 3 } }
          bm.report("#{type}#new#{size}") { iterations.times{ new.eval_array(type, size, default) } }
        end
      end

      result = Hash.new{|h, k| h[k] = [] }
      benchmarks.each do |r|
        key = case r.label
              when /\+/; :add
              when /-/; :sub
              when /\*/; :mult
              when /\//; :div
              when /new/; :new
              end
        result[key] << r.real
      end
      result
    end
  end

  def eval_array(type, size, default = 10)
    case type
    when /ruby/i
      Array.new(size, Array.new(size, default))
    when /cumo/i
      Cumo::Int32.new(size, size).fill(default)
    when /narray/i
      NArray.int(size, size).fill(default)
    when /numo/i
      Numo::Int32.new(size, size).fill(default)
    when /pycall/i
      np.array(Array.new(size, Array.new(size, default)), dtype: 'int32')
    end
  end
end

sizes = (0..4).map{|n| 10 ** n }
t_sizes = sizes[0...-1]
h_sizes = sizes[0...-2]

ruby = ArrayBenchmark.sec('ruby', sizes: h_sizes)
narray = ArrayBenchmark.sec('NArray', sizes: t_sizes)
numo = ArrayBenchmark.sec('Numo', sizes: t_sizes)
numpy = ArrayBenchmark.sec('PyCall', sizes: t_sizes)
cumo = ArrayBenchmark.sec('Cumo', sizes: sizes)

%i(add sub mult div new).each do |key|
  Numo.gnuplot do
    set terminal: {jpeg: {size: [1024, 768]}}
    set logscale: "x"
    set key: "left top"
    set title: "benchamrk array #{key.to_s} time"
    set xlabel: "square"
    set ylabel: "calc time(s)"
    set out: "#{dir}/bench-#{key.to_s}.jpg"

    numpy[key] = numpy[key][0..-2] if key == :new

    plot [*[sizes, ruby[key]],  {title: "Array", pointsize: 2}],
         [*[sizes, narray[key]],{title: "NArray", pointsize: 2}],
         [*[sizes, numo[key]], {title: "Numo::NArray", pointsize: 2}],
         [*[sizes, cumo[key]], {title: "Cumo::NArray", pointsize: 2}],
         [*[sizes, numpy[key]], {title: "numpy Array", pointsize: 2}]
  end
end
