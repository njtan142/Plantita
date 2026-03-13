'use client';

import { MediaModeration } from '@/types/api';
import { Badge } from '@/components/ui/badge';
import { 
  Flag,
  AlertTriangle,
  User
} from 'lucide-react';
import { format, parseISO } from 'date-fns';

interface FlagsAndWarningsProps {
  moderation?: MediaModeration;
}

export function FlagsAndWarnings({ moderation }: FlagsAndWarningsProps) {
  if (!moderation) return null;

  return (
    <div className="space-y-4">
      {moderation.flags && moderation.flags.length > 0 && (
        <div>
          <h3 className="font-medium mb-2 flex items-center">
            <Flag className="h-4 w-4 mr-2 text-yellow-500" />
            Content Flags
          </h3>
          <div className="space-y-2">
            {moderation.flags.map((flag, index) => (
              <div key={index} className="p-3 bg-yellow-50 border border-yellow-200 rounded-md">
                <div className="flex justify-between">
                  <span className="font-medium">{flag.type}</span>
                  <span className="text-sm text-gray-500">
                    {format(parseISO(flag.timestamp), 'MMM d, yyyy h:mm a')}
                  </span>
                </div>
                <p className="text-sm mt-1">{flag.reason}</p>
                {flag.moderatorId && (
                  <div className="flex items-center mt-2 text-xs text-gray-500">
                    <User className="h-3 w-3 mr-1" />
                    Moderator: {flag.moderatorId}
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      )}

      {moderation.warnings && moderation.warnings.length > 0 && (
        <div>
          <h3 className="font-medium mb-2 flex items-center">
            <AlertTriangle className="h-4 w-4 mr-2 text-orange-500" />
            Content Warnings
          </h3>
          <div className="space-y-2">
            {moderation.warnings.map((warning, index) => (
              <div key={index} className="p-3 bg-orange-50 border border-orange-200 rounded-md">
                <p className="text-sm">{warning}</p>
              </div>
            ))}
          </div>
        </div>
      )}

      {moderation.category && (
        <div>
          <h3 className="font-medium mb-2">Category</h3>
          <Badge variant="secondary">{moderation.category}</Badge>
        </div>
      )}
    </div>
  );
}
