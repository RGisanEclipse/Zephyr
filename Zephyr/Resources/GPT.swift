//
//  GPT.swift
//  Zephyr
//
//  Created by Eclipse on 25/12/24.
//

import Foundation

struct GPT{
    static let key = "pk-RopIzYQxIvdiwpfYCBdtcvzLKhXyvrSPMDzqUdPMrvpkKluk"
    static let url = "https://api.pawan.krd/v1"
    static let endpoint = "/chat/completions"
    static let prompt = "Generate a sentence from the next sentence, or rephrase. But don't write that you've generated it in the response. Just write the response of the prompt and that's it."
}
