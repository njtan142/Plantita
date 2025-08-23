'use client';

import { useState, useMemo } from 'react';
import { Media, MediaStatus } from '@/types/api';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { 
  Image as ImageIcon,
  Video,
  FileText,
  Filter,
  Search
} from 'lucide-react';
import { format, parseISO } from 'date-fns';

interface UserMediaGalleryProps {
  userId: string;
  media: Media[];
}

export function UserMediaGallery({ media }: UserMediaGalleryProps) {
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<MediaStatus | 'all'>('all');
  const [sortBy, setSortBy] = useState<'newest' | 'oldest' | 'name'>('newest');
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 12;

  // Filter and sort media
  const { filteredAndSortedMedia, totalPages, paginatedMedia } = useMemo(() => {
    let result = [...media];
    
    // Apply search filter
    if (searchTerm) {
      result = result.filter(item => 
        item.filename.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (item.description && item.description.toLowerCase().includes(searchTerm.toLowerCase())) ||
        (item.tags && item.tags.some(tag => tag.toLowerCase().includes(searchTerm.toLowerCase())))
      );
    }
    
    // Apply status filter
    if (statusFilter !== 'all') {
      result = result.filter(item => item.status === statusFilter);
    }
    
    // Apply sorting
    result.sort((a, b) => {
      switch (sortBy) {
        case 'newest':
          return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
        case 'oldest':
          return new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime();
        case 'name':
          return a.filename.localeCompare(b.filename);
        default:
          return 0;
      }
    });
    
    // Calculate pagination
    const total = Math.ceil(result.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginated = result.slice(startIndex, startIndex + itemsPerPage);
    
    return { filteredAndSortedMedia: result, totalPages: total, paginatedMedia: paginated };
  }, [media, searchTerm, statusFilter, sortBy, currentPage]);

  // Get media type icon
  const getMediaTypeIcon = (mimeType: string) => {
    if (mimeType.startsWith('image/')) {
      return <ImageIcon className="h-4 w-4" />;
    } else if (mimeType.startsWith('video/')) {
      return <Video className="h-4 w-4" />;
    } else {
      return <FileText className="h-4 w-4" />;
    }
  };

  // Get media type label
  const getMediaTypeLabel = (mimeType: string) => {
    if (mimeType.startsWith('image/')) {
      return 'Image';
    } else if (mimeType.startsWith('video/')) {
      return 'Video';
    } else {
      return 'File';
    }
  };

  // Get status badge variant
  const getStatusBadgeVariant = (status: MediaStatus) => {
    switch (status) {
      case MediaStatus.APPROVED:
        return 'default';
      case MediaStatus.PENDING:
        return 'secondary';
      case MediaStatus.REJECTED:
        return 'destructive';
      case MediaStatus.DELETED:
        return 'outline';
      default:
        return 'secondary';
    }
  };

  return (
    <Card>
      <CardContent className="p-6">
        {/* Filters and Search */}
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
          <div className="flex-1">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
              <Input
                placeholder="Search media..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>
          </div>
          
          <div className="flex flex-wrap gap-2">
            <div className="flex items-center space-x-2">
              <Filter className="h-4 w-4 text-gray-500" />
              <Select value={statusFilter} onValueChange={(value: MediaStatus | 'all') => setStatusFilter(value)}>
                <SelectTrigger className="w-[120px]">
                  <SelectValue placeholder="Status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Status</SelectItem>
                  <SelectItem value={MediaStatus.APPROVED}>Approved</SelectItem>
                  <SelectItem value={MediaStatus.PENDING}>Pending</SelectItem>
                  <SelectItem value={MediaStatus.REJECTED}>Rejected</SelectItem>
                  <SelectItem value={MediaStatus.DELETED}>Deleted</SelectItem>
                </SelectContent>
              </Select>
            </div>
            
            <Select value={sortBy} onValueChange={(value: 'newest' | 'oldest' | 'name') => setSortBy(value)}>
              <SelectTrigger className="w-[120px]">
                <SelectValue placeholder="Sort by" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="newest">Newest</SelectItem>
                <SelectItem value="oldest">Oldest</SelectItem>
                <SelectItem value="name">Name</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>

        {/* Media Grid */}
        {paginatedMedia.length === 0 ? (
          <div className="text-center py-12">
            <ImageIcon className="h-12 w-12 mx-auto text-gray-300 mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-1">No media found</h3>
            <p className="text-gray-500">
              {media.length === 0 
                ? "This user hasn't uploaded any media yet." 
                : "Try adjusting your search or filter criteria."}
            </p>
          </div>
        ) : (
          <>
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 mb-6">
              {paginatedMedia.map((item) => (
                <div key={item.id} className="group relative">
                  <Card className="overflow-hidden hover:shadow-md transition-shadow">
                    <div className="aspect-square bg-gray-100 relative">
                      {item.mimeType.startsWith('image/') ? (
                        // eslint-disable-next-line @next/next/no-img-element
                        <img
                          src={item.thumbnailUrl || item.url}
                          alt={item.description || item.filename}
                          className="w-full h-full object-cover"
                        />
                      ) : (
                        <div className="w-full h-full flex flex-col items-center justify-center p-4 text-gray-500">
                          <div className="bg-gray-200 rounded-full p-3 mb-2">
                            {getMediaTypeIcon(item.mimeType)}
                          </div>
                          <span className="text-xs text-center truncate w-full px-2">
                            {item.filename}
                          </span>
                        </div>
                      )}
                      
                      <div className="absolute top-2 right-2">
                        <Badge variant={getStatusBadgeVariant(item.status)}>
                          {item.status}
                        </Badge>
                      </div>
                    </div>
                    
                    <div className="p-3">
                      <div className="flex items-center justify-between mb-2">
                        <div className="flex items-center space-x-1 text-xs text-gray-500">
                          {getMediaTypeIcon(item.mimeType)}
                          <span>{getMediaTypeLabel(item.mimeType)}</span>
                        </div>
                        <div className="text-xs text-gray-500">
                          {format(parseISO(item.createdAt), 'MMM d, yyyy')}
                        </div>
                      </div>
                      
                      {item.description && (
                        <p className="text-sm text-gray-700 line-clamp-2 mb-2">
                          {item.description}
                        </p>
                      )}
                      
                      {item.tags && item.tags.length > 0 && (
                        <div className="flex flex-wrap gap-1">
                          {item.tags.slice(0, 3).map((tag, index) => (
                            <Badge key={index} variant="secondary" className="text-xs">
                              {tag}
                            </Badge>
                          ))}
                          {item.tags.length > 3 && (
                            <Badge variant="secondary" className="text-xs">
                              +{item.tags.length - 3}
                            </Badge>
                          )}
                        </div>
                      )}
                    </div>
                  </Card>
                </div>
              ))}
            </div>
            
            {/* Pagination */}
            {totalPages > 1 && (
              <div className="flex items-center justify-between border-t border-gray-200 pt-4">
                <div className="text-sm text-gray-700">
                  Showing {((currentPage - 1) * itemsPerPage) + 1} to {Math.min(currentPage * itemsPerPage, filteredAndSortedMedia.length)} of {filteredAndSortedMedia.length} results
                </div>
                
                <div className="flex items-center space-x-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
                    disabled={currentPage === 1}
                  >
                    Previous
                  </Button>
                  
                  <div className="flex items-center space-x-1">
                    {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
                      let pageNum;
                      if (totalPages <= 5) {
                        pageNum = i + 1;
                      } else if (currentPage <= 3) {
                        pageNum = i + 1;
                      } else if (currentPage >= totalPages - 2) {
                        pageNum = totalPages - 4 + i;
                      } else {
                        pageNum = currentPage - 2 + i;
                      }
                      
                      return (
                        <Button
                          key={pageNum}
                          variant={currentPage === pageNum ? "default" : "outline"}
                          size="sm"
                          onClick={() => setCurrentPage(pageNum)}
                        >
                          {pageNum}
                        </Button>
                      );
                    })}
                  </div>
                  
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
                    disabled={currentPage === totalPages}
                  >
                    Next
                  </Button>
                </div>
              </div>
            )}
          </>
        )}
      </CardContent>
    </Card>
  );
}