package kha;

import haxe.io.Bytes;

#if cpp
@:headerCode("
#include \"Direct3D11.h\"
")
class BackbufferCapture {
	@:functionCode("
		struct dx_window *window = &dx_ctx.windows[dx_ctx.current_window];
		if (window->backBuffer == NULL) {
			return null();
		}

		D3D11_TEXTURE2D_DESC sourceDesc;
		window->backBuffer->lpVtbl->GetDesc(window->backBuffer, &sourceDesc);

		ID3D11Texture2D *sourceTexture = window->backBuffer;
		ID3D11Texture2D *resolvedTexture = NULL;

		if (sourceDesc.SampleDesc.Count > 1) {
			D3D11_TEXTURE2D_DESC resolveDesc = sourceDesc;
			resolveDesc.SampleDesc.Count = 1;
			resolveDesc.SampleDesc.Quality = 0;
			resolveDesc.Usage = D3D11_USAGE_DEFAULT;
			resolveDesc.BindFlags = 0;
			resolveDesc.CPUAccessFlags = 0;
			resolveDesc.MiscFlags = 0;
			kinc_microsoft_affirm(dx_ctx.device->lpVtbl->CreateTexture2D(dx_ctx.device, &resolveDesc, NULL, &resolvedTexture));
			dx_ctx.context->lpVtbl->ResolveSubresource(dx_ctx.context, (ID3D11Resource *)resolvedTexture, 0, (ID3D11Resource *)window->backBuffer, 0,
			                                           sourceDesc.Format);
			sourceTexture = resolvedTexture;
			sourceDesc = resolveDesc;
		}

		D3D11_TEXTURE2D_DESC stagingDesc = sourceDesc;
		stagingDesc.Usage = D3D11_USAGE_STAGING;
		stagingDesc.BindFlags = 0;
		stagingDesc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
		stagingDesc.MiscFlags = 0;

		ID3D11Texture2D *stagingTexture = NULL;
		kinc_microsoft_affirm(dx_ctx.device->lpVtbl->CreateTexture2D(dx_ctx.device, &stagingDesc, NULL, &stagingTexture));
		dx_ctx.context->lpVtbl->CopyResource(dx_ctx.context, (ID3D11Resource *)stagingTexture, (ID3D11Resource *)sourceTexture);

		D3D11_MAPPED_SUBRESOURCE mappedResource;
		kinc_microsoft_affirm(dx_ctx.context->lpVtbl->Map(dx_ctx.context, (ID3D11Resource *)stagingTexture, 0, D3D11_MAP_READ, 0, &mappedResource));

		const int bytesPerPixel = 4;
		const int packedRowSize = sourceDesc.Width * bytesPerPixel;
		::haxe::io::Bytes result = ::haxe::io::Bytes_obj::alloc(packedRowSize * sourceDesc.Height);
		uint8_t *destination = result->b->Pointer();
		uint8_t *source = (uint8_t *)mappedResource.pData;

		for (UINT y = 0; y < sourceDesc.Height; ++y) {
			memcpy(destination + (y * packedRowSize), source + (y * mappedResource.RowPitch), packedRowSize);
		}

		dx_ctx.context->lpVtbl->Unmap(dx_ctx.context, (ID3D11Resource *)stagingTexture, 0);
		stagingTexture->lpVtbl->Release(stagingTexture);
		if (resolvedTexture != NULL) {
			resolvedTexture->lpVtbl->Release(resolvedTexture);
		}

		return result;
	")
	public static function capture():Bytes {
		return null;
	}
}
#else
class BackbufferCapture {
	public static function capture():Bytes {
		return null;
	}
}
#end
