import apiClient from '@/lib/api-client';
import {
  Media,
  UpdateMediaData,
  MediaQueryParams,
  MediaStats,
  ApiResponse
} from '@/types/api';

export class MediaService {
  // Get paginated list of media
  async getMedia(params?: MediaQueryParams): Promise<ApiResponse<Media[]>> {
    const queryParams = new URLSearchParams();

    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.limit) queryParams.append('limit', params.limit.toString());
    if (params?.sort) queryParams.append('sort', params.sort);
    if (params?.order) queryParams.append('order', params.order);
    if (params?.search) queryParams.append('search', params.search);
    if (params?.type) queryParams.append('type', params.type);
    if (params?.status) queryParams.append('status', params.status);
    if (params?.uploadedBy) queryParams.append('uploadedBy', params.uploadedBy);
    if (params?.tags) queryParams.append('tags', params.tags.join(','));
    if (params?.createdAfter) queryParams.append('createdAfter', params.createdAfter);
    if (params?.createdBefore) queryParams.append('createdBefore', params.createdBefore);
    if (params?.sizeMin) queryParams.append('sizeMin', params.sizeMin.toString());
    if (params?.sizeMax) queryParams.append('sizeMax', params.sizeMax.toString());

    const url = `/media${queryParams.toString() ? `?${queryParams.toString()}` : ''}`;
    return apiClient.get<Media[]>(url);
  }

  // Get media by ID
  async getMediaById(id: string): Promise<ApiResponse<Media>> {
    return apiClient.get<Media>(`/media/${id}`);
  }

  // Upload new media
  async uploadMedia(formData: FormData): Promise<ApiResponse<Media>> {
    return apiClient.upload<Media>('/media/upload', formData);
  }

  // Update media
  async updateMedia(id: string, mediaData: UpdateMediaData): Promise<ApiResponse<Media>> {
    return apiClient.put<Media>(`/media/${id}`, mediaData);
  }

  // Delete media
  async deleteMedia(id: string): Promise<ApiResponse<void>> {
    return apiClient.delete<void>(`/media/${id}`);
  }

  // Bulk delete media
  async bulkDeleteMedia(mediaIds: string[]): Promise<ApiResponse<{ deletedCount: number }>> {
    return apiClient.post<{ deletedCount: number }>('/media/bulk-delete', { mediaIds });
  }

  // Approve media
  async approveMedia(id: string): Promise<ApiResponse<Media>> {
    return apiClient.patch<Media>(`/media/${id}/approve`, {});
  }

  // Reject media
  async rejectMedia(id: string, reason?: string): Promise<ApiResponse<Media>> {
    return apiClient.patch<Media>(`/media/${id}/reject`, { reason });
  }

  // Get media statistics
  async getMediaStats(): Promise<ApiResponse<MediaStats>> {
    return apiClient.get<MediaStats>('/media/stats');
  }

  // Get media by user
  async getMediaByUser(userId: string, params?: Omit<MediaQueryParams, 'uploadedBy'>): Promise<ApiResponse<Media[]>> {
    const queryParams = new URLSearchParams();
    queryParams.append('uploadedBy', userId);

    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.limit) queryParams.append('limit', params.limit.toString());
    if (params?.sort) queryParams.append('sort', params.sort);
    if (params?.order) queryParams.append('order', params.order);
    if (params?.search) queryParams.append('search', params.search);
    if (params?.type) queryParams.append('type', params.type);
    if (params?.status) queryParams.append('status', params.status);
    if (params?.tags) queryParams.append('tags', params.tags.join(','));
    if (params?.createdAfter) queryParams.append('createdAfter', params.createdAfter);
    if (params?.createdBefore) queryParams.append('createdBefore', params.createdBefore);
    if (params?.sizeMin) queryParams.append('sizeMin', params.sizeMin.toString());
    if (params?.sizeMax) queryParams.append('sizeMax', params.sizeMax.toString());

    const url = `/media?${queryParams.toString()}`;
    return apiClient.get<Media[]>(url);
  }

  // Search media by content
  async searchMedia(query: string, params?: Omit<MediaQueryParams, 'search'>): Promise<ApiResponse<Media[]>> {
    const queryParams = new URLSearchParams();
    queryParams.append('search', query);

    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.limit) queryParams.append('limit', params.limit.toString());
    if (params?.sort) queryParams.append('sort', params.sort);
    if (params?.order) queryParams.append('order', params.order);
    if (params?.type) queryParams.append('type', params.type);
    if (params?.status) queryParams.append('status', params.status);
    if (params?.uploadedBy) queryParams.append('uploadedBy', params.uploadedBy);
    if (params?.tags) queryParams.append('tags', params.tags.join(','));
    if (params?.createdAfter) queryParams.append('createdAfter', params.createdAfter);
    if (params?.createdBefore) queryParams.append('createdBefore', params.createdBefore);
    if (params?.sizeMin) queryParams.append('sizeMin', params.sizeMin.toString());
    if (params?.sizeMax) queryParams.append('sizeMax', params.sizeMax.toString());

    const url = `/media/search?${queryParams.toString()}`;
    return apiClient.get<Media[]>(url);
  }

  // Get media download URL
  async getMediaDownloadUrl(id: string): Promise<string> {
    const response = await apiClient.get<{ downloadUrl: string }>(`/media/${id}/download`);
    return response.data?.downloadUrl || '';
  }

  // Get media thumbnail URL
  async getMediaThumbnailUrl(id: string, size?: 'small' | 'medium' | 'large'): Promise<string> {
    const queryParams = new URLSearchParams();
    if (size) queryParams.append('size', size);

    const url = `/media/${id}/thumbnail${queryParams.toString() ? `?${queryParams.toString()}` : ''}`;
    const response = await apiClient.get<{ thumbnailUrl: string }>(url);
    return response.data?.thumbnailUrl || '';
  }

  // Export media metadata
  async exportMedia(params?: MediaQueryParams): Promise<Blob> {
    const queryParams = new URLSearchParams();

    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.limit) queryParams.append('limit', params.limit.toString());
    if (params?.sort) queryParams.append('sort', params.sort);
    if (params?.order) queryParams.append('order', params.order);
    if (params?.search) queryParams.append('search', params.search);
    if (params?.type) queryParams.append('type', params.type);
    if (params?.status) queryParams.append('status', params.status);
    if (params?.uploadedBy) queryParams.append('uploadedBy', params.uploadedBy);
    if (params?.tags) queryParams.append('tags', params.tags.join(','));

    const url = `/media/export${queryParams.toString() ? `?${queryParams.toString()}` : ''}`;

    const response = await apiClient.getAxiosInstance().get(url, {
      responseType: 'blob',
    });

    return response.data;
  }
}

// Export singleton instance
export const mediaService = new MediaService();
export default mediaService;