'use client';

import { Badge } from '@/components/ui/badge';
import { Tag } from 'lucide-react';
import { CommunicationTemplate } from '@/types/api';

interface TemplatePreviewProps {
  template: CommunicationTemplate;
}

export function TemplatePreview({ template }: TemplatePreviewProps) {
  return (
    <div className="space-y-4">
      <div>
        <h4 className="font-semibold">Subject</h4>
        <p className="text-sm">{template.subject}</p>
      </div>
      <div>
        <h4 className="font-semibold">Body</h4>
        <div className="text-sm whitespace-pre-wrap border rounded p-3 bg-muted">
          {template.body}
        </div>
      </div>
      {template.variables.length > 0 && (
        <div>
          <h4 className="font-semibold">Variables</h4>
          <div className="flex flex-wrap gap-2 mt-2">
            {template.variables.map((variable, index) => (
              <Badge key={index} variant="secondary" className="flex items-center gap-1">
                <Tag className="h-3 w-3" />
                {variable}
              </Badge>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
