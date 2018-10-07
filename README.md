## What is this?

技術書典で書いた薄い本に記載しているベンチマークのプログラム

## How to run?

### Install Packages

```
git clone git@github.com:katsyoshi/gishoten5-bench.git
cd gishoten5-bench
bundle install
```

Cumoがインストールできない場合は以下のURL参照してね
https://blog.katsyoshi.org/blog/2018/09/11/cumo/


### Run benchmarks

```
bundle exec ruby benchmark-narray.rb
benchmark-driver -o simple memory.yml
benchmark-driver -r once -o simple memory.yml
benchmark-driver -r memory -o simple memory.yml
benchmark-driver -o simple narray.yml
benchmark-driver -r once -o simple narray.yml
benchmark-driver -r memory -o simple narray.yml
```

## License
[MIT](LICENSE)
