defmodule RSSTest do
  use ExUnit.Case

  test "build an item definition" do
    title = "Cats love <lasers>"
    link = "http://mycatblog/cats-love-lasers?lover=cats&lovee=lasers"
    guid = "http://mycatblog/cats-love-lasers"
    desc = "Combining the awesomeness of cats & lasers"
    pubDate = "Mon, 12 Sep 2005 18:37:00 GMT"
    item = RSS.item(title, desc, pubDate, link, guid)

    assert xml_parsing_error(item) == nil
    assert item == """
    <item>
      <title>Cats love &lt;lasers&gt;</title>
      <description>Combining the awesomeness of cats &amp; lasers</description>
      <pubDate>#{pubDate}</pubDate>
      <link>http://mycatblog/cats-love-lasers?lover=cats&amp;lovee=lasers</link>
      <guid>#{guid}</guid>
    </item>
    """
  end

  test "build a channel definition" do
    title = "Good Cat <Blog>"
    link = "http://goodcats.bestblog.com/blog?subject=cats&bad=false"
    desc = "A blog about cats & how good they are"
    date = "Mon, 12 Sep 2005 18:37:00 GMT"
    lang = "en-us"
    channel = RSS.channel(title, link, desc, date, lang)

    assert xml_parsing_error(channel) == nil
    assert channel == """
      <title>Good Cat &lt;Blog&gt;</title>
      <link>http://goodcats.bestblog.com/blog?subject=cats&amp;bad=false</link>
      <description>A blog about cats &amp; how good they are</description>
      <lastBuildDate>#{date}</lastBuildDate>
      <language>#{lang}</language>
    """
  end

  test "build feed" do
    channel = RSS.channel("Test blog", "http://test.blog", "This is a test blog", "Mon, 12 Sep 2005 18:37:00 GMT", "en-us")
    item2 = RSS.item("Post 2", "The second post", "Mon, 12 Sep 2005 18:37:00 GMT", "http://test.blog/two", "http://test.blog/two")
    item1 = RSS.item("Post 1", "The first post", "Sun, 11 Sep 2005 18:37:00 GMT", "http://test.blog/one", "http://test.blog/one")
    feed = RSS.feed(channel, [item2, item1])

    assert xml_parsing_error(feed) == nil
    assert feed == """
    <?xml version="1.0" encoding="utf-8"?>
    <rss version="2.0">
    <channel>
      <title>Test blog</title>
      <link>http://test.blog</link>
      <description>This is a test blog</description>
      <lastBuildDate>Mon, 12 Sep 2005 18:37:00 GMT</lastBuildDate>
      <language>en-us</language>
    <item>
      <title>Post 2</title>
      <description>The second post</description>
      <pubDate>Mon, 12 Sep 2005 18:37:00 GMT</pubDate>
      <link>http://test.blog/two</link>
      <guid>http://test.blog/two</guid>
    </item>
    <item>
      <title>Post 1</title>
      <description>The first post</description>
      <pubDate>Sun, 11 Sep 2005 18:37:00 GMT</pubDate>
      <link>http://test.blog/one</link>
      <guid>http://test.blog/one</guid>
    </item>
    </channel>
    </rss>
    """
  end

  defp xml_parsing_error(xml) do
    try do
      xml
      |> :binary.bin_to_list
      |> :xmerl_scan.string([quiet: true])

      nil
    catch
      :exit, error -> error
    end
  end
end
