"""
DotCorrector 后端单元测试
覆盖：词典纠错、路径处理、文件解析、导出
"""

import os
import sys
import json
import tempfile
import unittest
from pathlib import Path

# 只导入不依赖 PySide6 的函数
sys.path.insert(0, str(Path(__file__).parent))

from backend import dict_correct, _safe_path, TYPO_DICT


class TestSafePath(unittest.TestCase):
    """测试 _safe_path 路径转换"""

    def test_file_url_windows(self):
        self.assertEqual(_safe_path("file:///C:/Users/test.txt"), "C:/Users/test.txt")

    def test_file_url_unix(self):
        self.assertEqual(_safe_path("file:///home/user/test.txt"), "/home/user/test.txt")

    def test_file_url_host(self):
        self.assertEqual(_safe_path("file://host/share/file.txt"), "/share/file.txt")

    def test_plain_path(self):
        self.assertEqual(_safe_path("/home/user/test.txt"), "/home/user/test.txt")

    def test_url_encoded_spaces(self):
        self.assertEqual(_safe_path("file:///C:/My%20Documents/test.txt"), "C:/My Documents/test.txt")

    def test_url_encoded_chinese(self):
        self.assertEqual(_safe_path("file:///C:/%E6%96%87%E6%A1%A3/test.txt"), "C:/文档/test.txt")

    def test_empty_string(self):
        self.assertEqual(_safe_path(""), "")

    def test_no_prefix(self):
        self.assertEqual(_safe_path("relative/path.txt"), "relative/path.txt")


class TestDictCorrect(unittest.TestCase):
    """测试词典纠错"""

    def test_basic_typo(self):
        """基本错别字修正"""
        text = "你应该在说一遍"
        changes, corrected = dict_correct(text)
        self.assertIn("再次", corrected)
        self.assertTrue(len(changes) > 0)

    def test_idiom_typo(self):
        """成语错别字修正"""
        text = "他走头无路了"
        changes, corrected = dict_correct(text)
        self.assertIn("走投无路", corrected)

    def test_no_typo(self):
        """无错别字时不变"""
        text = "这是一段完全正确的文本"
        changes, corrected = dict_correct(text)
        self.assertEqual(len(changes), 0)
        self.assertEqual(corrected, text)

    def test_empty_text(self):
        """空文本"""
        changes, corrected = dict_correct("")
        self.assertEqual(len(changes), 0)
        self.assertEqual(corrected, "")

    def test_multiple_typos(self):
        """多个错别字"""
        text = "以经走头无路的他"
        changes, corrected = dict_correct(text)
        self.assertIn("已经", corrected)
        self.assertIn("走投无路", corrected)

    def test_word_boundary_no_false_positive(self):
        """短词不应误匹配——检查词边界保护"""
        # "刻划" → "刻画"，但 "时刻划分" 不应被误改
        # 注意：这取决于词典中是否包含 "刻划"
        text = "我们需要时刻划分清楚"
        changes, corrected = dict_correct(text)
        # "划分" 是合法词汇，不应被替换
        self.assertIn("划分", corrected)

    def test_position_accuracy(self):
        """位置信息准确"""
        text = "他的以经走了"
        changes, corrected = dict_correct(text)
        for ch in changes:
            # 验证原文位置确实指向正确的子串
            pos = ch["position"]
            orig = ch["original"]
            self.assertEqual(text[pos:pos + len(orig)], orig,
                             f"位置 {pos} 不指向 '{orig}'，实际文本为 '{text[pos:pos+len(orig)]}'")

    def test_chengyu_4char_boundary_skipped(self):
        """4字成语不做边界检查（几乎不会误报）"""
        text = "他穿流不息地走着"
        changes, corrected = dict_correct(text)
        self.assertIn("川流不息", corrected)

    def test_dict_completeness(self):
        """词典中每个条目都是 wrong→right 映射"""
        for wrong, right in TYPO_DICT.items():
            self.assertIsInstance(wrong, str)
            self.assertIsInstance(right, str)
            self.assertNotEqual(wrong, right, f"'{wrong}' 映射到自身")
            self.assertTrue(len(wrong) >= 2, f"'{wrong}' 长度不足2")


class TestFileParsing(unittest.TestCase):
    """测试文件解析（需要 PySide6，跳过）"""

    def test_txt_parsing(self):
        """TXT 文件解析"""
        from backend import extract_text_from_file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False, encoding='utf-8') as f:
            f.write("测试文本\n第二段")
            tmp_path = f.name

        try:
            segments, file_type = extract_text_from_file(tmp_path)
            self.assertEqual(file_type, "txt")
            self.assertEqual(len(segments), 1)
            self.assertIn("测试文本", segments[0]["text"])
        finally:
            os.unlink(tmp_path)

    def test_unsupported_format(self):
        """不支持的格式应抛出异常"""
        from backend import extract_text_from_file
        with tempfile.NamedTemporaryFile(suffix='.pdf', delete=False) as f:
            tmp_path = f.name
        try:
            with self.assertRaises(ValueError):
                extract_text_from_file(tmp_path)
        finally:
            os.unlink(tmp_path)


class TestExport(unittest.TestCase):
    """测试文件导出"""

    def test_txt_export(self):
        """TXT 文件导出"""
        from backend import export_corrected_file
        with tempfile.TemporaryDirectory() as tmpdir:
            output_path = os.path.join(tmpdir, "output.txt")
            segments = [{"corrected_text": "修正后的文本", "ref": None}]
            export_corrected_file(segments, "txt", output_path, "")

            with open(output_path, 'r', encoding='utf-8') as f:
                content = f.read()
            self.assertEqual(content, "修正后的文本")


class TestLLMJsonParsing(unittest.TestCase):
    """测试 LLM JSON 解析健壮性（模拟）"""

    def test_clean_json(self):
        """干净的 JSON"""
        content = '{"corrections": [{"position": 0, "original": "以经", "corrected": "已经"}]}'
        result = json.loads(content)
        self.assertEqual(len(result["corrections"]), 1)

    def test_json_with_markdown(self):
        """带 markdown 代码块的 JSON"""
        content = '```json\n{"corrections": []}\n```'
        content = __import__('re').sub(r"```(?:json)?\s*", "", content)
        content = __import__('re').sub(r"```\s*$", "", content)
        result = json.loads(content.strip())
        self.assertEqual(result["corrections"], [])

    def test_json_with_surrounding_text(self):
        """JSON 周围有额外文本"""
        content = '好的，以下是纠错结果：\n{"corrections": [{"position": 0, "original": "x", "corrected": "y"}]}\n希望对你有帮助。'
        # 提取外层 {}
        brace_start = content.find("{")
        depth = 0
        result = None
        for ci in range(brace_start, len(content)):
            if content[ci] == "{":
                depth += 1
            elif content[ci] == "}":
                depth -= 1
                if depth == 0:
                    result = json.loads(content[brace_start:ci + 1])
                    break
        self.assertIsNotNone(result)
        self.assertEqual(len(result["corrections"]), 1)


class TestProgressCalculation(unittest.TestCase):
    """测试进度计算"""

    def test_progress_formula(self):
        """多文件进度应单调递增到 100"""
        # 模拟：file1 有 3 段，file2 有 2 段，共 5 段
        total = 5
        progress_values = []
        for i in range(total):
            pct = int(((i + 1) / total) * 100)
            progress_values.append(pct)

        # 单调递增
        for i in range(1, len(progress_values)):
            self.assertGreaterEqual(progress_values[i], progress_values[i - 1])
        # 最终为 100
        self.assertEqual(progress_values[-1], 100)


if __name__ == '__main__':
    unittest.main(verbosity=2)
