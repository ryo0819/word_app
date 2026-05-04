# VocabApp (IT Vocabulary Learning)

IT英単語を効率的に学習するためのSwiftUIアプリケーション。
もともと医療系単語アプリとして開発されていましたが、現在はIT単語学習に特化した構成になっています。

## プロジェクト構成

- **App Entry**: `VocabApp.swift` (旧 MedicalVocabApp.swift)
- **Model**: `Word.swift` (SwiftDataを使用。SM-2アルゴリズムによる復習スケジューリングを実装)
- **Views**:
    - `ContentView`: メイン画面。学習セッションの開始と進捗統計の表示。
    - `StudyView`: クイズ形式の学習画面。単語の意味（`context`）を選択肢として提示。
    - `FlashcardView`: 単語カード形式の学習。
    - `WordListView`: 登録単語の一覧・検索・編集。
    - `AddWordView` / `EditWordView`: 単語の追加・編集。
- **Data**:
    - `initial_words.csv`: IT英単語100選のデータ。
    - `DataLoader.swift`: CSVからの初期データ読み込み。起動時に既存データをクリアし、IT単語に入れ替えるロジックを保持。

## 技術スタック

- **Framework**: SwiftUI
- **Database**: SwiftData
- **Algorithm**: SM-2 (SRS: 間隔反復学習)

## 重要な規約と変更履歴

1. **プロパティ名の変更**:
    - `Word` モデルの `medicalContext` は `context` にリネームされました。
    - スキーマ互換性のため、`@Attribute(originalName: "medicalContext")` が付与されています。
2. **学習ロジック**:
    - `StudyView` のクイズ形式は、「英単語」に対して「意味（説明文 / `context`）」を選択させる形式です。
3. **データ管理**:
    - `initial_words.csv` はIT単語で構成されています。
    - 現在はカテゴリ分けを行わず、すべての単語をフラットに管理しています。

## 開発メモ

- プレビューには `PreviewContainer.swift` のインメモリコンテナを使用してください。
- 新しい単語を追加する際は、`context` 欄に十分な説明を記載することで、クイズの質が向上します。
- `word_app.xcodeproj` 以下のディレクトリ構造は、プロジェクトファイルとの整合性を維持するため、移動の際は注意が必要です。
