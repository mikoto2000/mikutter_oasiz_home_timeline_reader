# -*- coding: utf-8 -*-

Plugin.create(:oasiz_home_timeline_reader) do

    @mikutter_start_time = nil

    # config に設定項目を追加
    settings("ホームタイムライン読み上げ") do
        settings("基本設定") do
            boolean '読み上げ有効', :oasiz_home_timeline_reader_is_enable
        end
    end

    # mikutter 起動時間記録
    on_boot do |service|
        UserConfig[:oasiz_home_timeline_reader_is_enable] ||= true
        @mikutter_start_time = Time.now
    end

    # ホームタイムライン更新イベント
    on_update do |service, messages|
        # 音声読み上げが OFF であれば何もしない
        unless UserConfig[:oasiz_home_timeline_reader_is_enable] then
            return
        end

        for message in messages do
            # mikutter 起動以前のツイートは無視
            if message[:created] < @mikutter_start_time then
                next
            end

            # メッセージリビルドプラグインにリビルド依頼
            read_text = Plugin.filtering(:rebuild_message, message)[0].to_show

            # リビルド後のテキストを読み上げ依頼
            Plugin.filtering(:voicetext_read, read_text)
        end
    end
end
