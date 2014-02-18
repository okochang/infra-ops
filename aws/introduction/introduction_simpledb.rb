# -*- coding: utf-8 -*-
require 'net/http'
require 'aws-sdk'
sdb_region  = 'sdb.' + Net::HTTP.get('169.254.169.254', '/latest/meta-data/placement/availability-zone').chop + '.amazonaws.com'
domain_name = "milan_no_10"

@sdb = AWS::SimpleDB.new(:simple_db_endpoint => sdb_region)
## ドメインを作成する
mydomain = @sdb.domains.create(domain_name)

## 作成したドメインを確認する
mydomain.exists?

## 作成したドメインにアイテムを登録する
mydomain.items.create("Keisuke Honda", {
  "Country" => "Japan",
  "Number" => "10"})

## 作成したドメインを削除する
mydomain.delete!
