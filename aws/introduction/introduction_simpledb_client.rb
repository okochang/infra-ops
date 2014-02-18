# -*- coding: utf-8 -*-
require 'net/http'
require 'aws-sdk'
sdb_region  = 'sdb.' + Net::HTTP.get('169.254.169.254', '/latest/meta-data/placement/availability-zone').chop + '.amazonaws.com'
domain_name = "milan_no_10"

@sdb = AWS::SimpleDB.new(:simple_db_endpoint => sdb_region).client

## Domainを作成する
@sdb.create_domain(:domain_name => domain_name)

## 作成されているDomainの一覧を見る
@sdb.list_domains

## Domainのメタデータを確認する
@sdb.domain_metadata(:domain_name => domain_name)

## Itemを追加する
@sdb.put_attributes(
  :domain_name => domain_name,
  :item_name => "Keisuke Honda",
  :attributes => [{ :name => "Country", :value => "Japan"}, { :name => "Number", :value => "10"}]
  )

## 追加したItemを見る
@sdb.get_attributes(:domain_name => domain_name, :item_name => "Keisuke Honda")

## Attributeを削除する
@sdb.delete_attributes(:domain_name => domain_name, :item_name => "Keisuke Honda", :attributes => [{ :name => "Number", :value => "10" }])

## 追加したItemを削除する
@sdb.delete_attributes(:domain_name => domain_name, :item_name => "Keisuke Honda")

## 一度に複数のItemを追加する
@sdb.batch_put_attributes(:domain_name => domain_name,
  :items => [
    { :name => "Keisuke Honda", :attributes => [{ :name => "Country", :value => "Japan"}, { :name => "Number", :value => "10"}] },
    { :name => "Zvonimir Boban", :attributes => [{ :name => "Country", :value => "Croatia" }, { :name => "Number", :value => "10" }] },
    { :name => "Rui Costa", :attributes => [{ :name => "Country", :value => "Portugal" }, { :name => "Number", :value => "10" }] }
    ])

## ドメイン内のアイテムを取得する
@sdb.select(:select_expression => "select Country from milan_no_10")

## 一度に複数のAttributeを削除する
@sdb.batch_delete_attributes(:domain_name => domain_name,
  :items => [
    { :name => "Keisuke Honda", :attributes => [{ :name => "Country", :value => "Japan" }] },
    { :name => "Rui Costa", :attributes => [{ :name => "Number", :value => "10" }] }
  ])

## 一度に複数のItemを削除する
@sdb.batch_delete_attributes(:domain_name => domain_name,
  :items => [
    { :name => "Keisuke Honda"},
    { :name => "Rui Costa"}
  ])

## Domainを削除する
@sdb.delete_domain(:domain_name => domain_name)
