namespace :test do
  desc "テスト用データ引き当て"
  task :test_task => :environment do
    # テスト用データを引き当てる処理をここに記述
    # 例: Product.create(name: "テスト商品", price: 1000)
    puts "テスト用データを引き当てました"
  
  #  **products テーブル**
  #  
  #  |id|name|price|
  #  |--|----|-----|
  #  |1 |商品A|1000 |
  #  |2 |商品B|2000 |
  #  
  #  **product_options テーブル**
  #  
  #  |id|product_id|feature_category|option_value|
  #  |--|----------|----------------|------------|
  #  |1 |1         |color          |RED         |
  #  |2 |1         |size         |L          |
  #  |3 |2         |color          |BLUE         |
  #  |4 |2         |size         |M          |
  #
  # データ引き当てに当たって以下のような構造で一発で引き当てたい。
  # 
  # |id|name|price|color|size|
  # |--|----|-----|---|----|
  # |1 |商品A|1000 |RED|L|
  
    result = Product.joins(:product_options)
         .select("products.id, products.name, products.price, product_options.feature_category, product_options.option_value")
         .where("product_options.feature_category = 'color' OR product_options.feature_category = 'size'")
 
    # この方法では以下のように取得されており間違いである。
    #[#<Product:0x00007fc0e2c10db8 id: 1, name: "商品A", price: 0.1e4, feature_category: "color", option_value: "RED">,
    # #<Product:0x00007fc0e5a73fc0 id: 1, name: "商品A", price: 0.1e4, feature_category: "size", option_value: "L">,
    # #<Product:0x00007fc0e5a73e80 id: 2, name: "商品B", price: 0.2e4, feature_category: "color", option_value: "BLUE">,
    # #<Product:0x00007fc0e5a73d40 id: 2, name: "商品B", price: 0.2e4, feature_category: "size", option_value: "M">]

    result = Product.joins(:product_options)
         .select("products.id, products.name, products.price,
                  MAX(CASE WHEN product_options.feature_category = 'color' THEN product_options.option_value END) AS color,
                  MAX(CASE WHEN product_options.feature_category = 'size' THEN product_options.option_value END) AS size")
#                  MAX(CASE WHEN product_options.feature_category = 'size2' THEN product_options.option_value END) AS size2")
         .group("products.id, products.name, products.price")
         .having("color IS NOT NULL")
         .having("size IS NOT NULL")
#         .having("size2 IS NOT NULL")
    pp result

    pp "##"

    # この方法で取得される。
    # [#<Product:0x00007fc0e2c10db8 id: 1, name: "商品A", price: 0.1e4, color: "RED", size: "L">,
    #  #<Product:0x00007fc0e5a73fc0 id: 2, name: "商品B", price: 0.2e4, color: "BLUE", size: "M">]

    # 別解として全カラム埋まっていることを前提としないならシンプルに以下のように記述できる    
    result = Product
         #.where(id: 1)
         .joins(:product_options)
         .select("products.id, products.name, products.price,
                  MAX(CASE WHEN product_options.feature_category = 'color' THEN product_options.option_value END) AS color,
                  MAX(CASE WHEN product_options.feature_category = 'size' THEN product_options.option_value END) AS size")
         .group("products.id")


         
    pp result

    result = Product
    .where(id: 1)
    .joins(:product_options)
    .select("products.id, products.name, products.price,
             MAX(CASE WHEN product_options.feature_category = 'color' THEN product_options.option_value END) AS color,
             MAX(CASE WHEN product_options.feature_category = 'size' THEN product_options.option_value END) AS size")
    .group("products.id")

    pp result

    pp "##"
    result = Product.with_product_options
    
    pp result

    pp "##"
    # feature_category で取りうるオプションを動的に与えるには
    product_id = 1
    feature_category = ProductOption.where(product_id: product_id).pluck(:feature_category)

    dynamic_definition_query = 
      feature_category.map do |category|
        "MAX(CASE WHEN product_options.feature_category = '#{category}' THEN product_options.option_value END) AS #{category}"
      end

    result = Product.joins(:product_options).select("products.id, products.name, products.price, #{dynamic_definition_query.join(', ')}").group("products.id")

    pp result
  end

  desc "テスト用データ引き当て3"
  task :test_task3 => :environment do

    # オプションすべてを取得する
    result = Product.joins(:product_options).with_options()
    
    pp "--0--"
    pp result[0]
    pp "result[0].color     :#{result[0].color}"
    pp "result[0].size      :#{result[0].size}"
    pp "result[0].weight    :#{result[0].weight}"
    pp "result[0].tolerance :#{result[0].tolerance}"
    pp "result[0].tolerance.cover(0.05) :#{result[0].tolerance.cover?(0.05)}"
    pp "result[0].stack     :#{result[0].stack}"

    pp "--1--"
    # オプションの一部(color)を取得する
    result = Product.joins(:product_options).where(id: 51).with_options(["color"]).first
    pp "result.color     :#{result.color}"
    pp "result.size      :#{result.size}"
    pp "result.weight    :#{result.weight}"
    pp "result.serial    :#{result.serial}"
    pp "result.stack     :#{result.stack}"
  end
end