@setlocal enabledelayedexpansion&set a=%*&(if defined a set a=!a:"=\"!&set a=!a:'=''!)&powershell/c $i=$input;iex ('$i^|^&{$PSCommandPath=\"%~f0\";$PSScriptRoot=\"%~dp0";#'+(${%~f0}^|Out-String)+'} '+('!a!'-replace'[$(),;@`{}]','`$0'))&exit/b
# 詳細：http://reosablo.hatenablog.jp/entry/2016/07/09/193617

# 文字コードの都合により、当該ファイル名称にはマルチバイト文字を使用できない。

# バージョン確認
$PSVersion = [string]$PSVersionTable.PSVersion.Major + '.' + [string]$PSVersionTable.PSVersion.Minor + '.' + [string]$PSVersionTable.PSVersion.Revision
Write-Host "PowerShellバージョン: $PSVersion"

# .netアセンブリのロード
[void][System.Reflection.Assembly]::LoadWithPartialName('System.IO')
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[void][System.Windows.Forms.Application]::EnableVisualStyles()

function CreateNotifyIconMenu {
    # menuItem1オブジェクトの作成
    $menuItem1 = new-object System.Windows.Forms.MenuItem('終了(&X)')
     
    # Clickイベント
    $menuItem1.Add_Click({Form_Closing})
     
    # contextMenuオブジェクトの作成
    $contextMenu = new-object System.Windows.Forms.ContextMenu
     
    # menuItemオブジェクトをcontextMenuオブジェクトのMenuItemsコレクションに追加
    [void]$contextMenu.MenuItems.Add($menuItem1)
    #↑ここの[void]を忘れるとAddメソッドの戻り値がreturnされてしまう。
     
    return ($contextMenu)
}

function Form_Closing {
    # フォームとシステムトレイアイコンを非表示に
    $form.Visible = $false
    #$notifyIcon.Visible = $false
}

# notifyIconオブジェクトの作成とプロパティの設定
$notifyIcon = new-object System.Windows.Forms.NotifyIcon
# System.Drawing.Iconクラスのコンストラクタにはicoファイルのパスを指定する。(このスクリプトと同じ階層に配置したもの)
$notifyIcon.Icon = new-object System.Drawing.Icon ([System.IO.Path]::Combine($($PSScriptRoot),'form.ico'))
$notifyIcon.Text = 'PowerShell実行中'
$notifyIcon.ContextMenu = CreateNotifyIconMenu
$notifyIcon.Visible = $true

# formオブジェクトの作成
$form = new-object System.Windows.Forms.Form
# formスタイル
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
# form初期位置
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
# formアイコン
$form.Icon = new-object System.Drawing.Icon ([System.IO.Path]::Combine($($PSScriptRoot),'form.ico'))
# formタイトル
$form.Text = 'Formテスト'
# Closingイベント
$form.Add_Closing({Form_Closing})

# フォームの表示
Write-Host -ForegroundColor Yellow "(実行中)`r`n"
[void]$form.showDialog()

# 終了メッセージ
#Write-Host '終了するには何かキーを押してください . . . ' -NoNewline
#[void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown,IncludeKeyUp')