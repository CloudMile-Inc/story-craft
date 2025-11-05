# StoryCraft Application Architecture & Deployment Guide

## Overview

StoryCraft is an AI-powered video storyboard generation platform that transforms text descriptions into complete video narratives using Google's generative AI models. The application provides a complete workflow from story concept to finished video, featuring a timeline-based editor for precise control over video composition.

## Application Architecture

### Technology Stack

**Frontend & Framework:**
- **Next.js 15** - React framework with App Router and server actions
- **React 18** - UI library with modern hooks and concurrent features
- **TypeScript** - Type-safe development
- **Tailwind CSS** - Utility-first CSS framework with custom design system
- **Framer Motion** - Animation library for smooth UI transitions
- **Radix UI** - Accessible component primitives

**AI & Machine Learning:**
- **Google Vertex AI** - Imagen 4.0 for image generation, Veo 3.0 for video creation
- **Google Cloud Text-to-Speech** - Chirp 3 neural voice synthesis
- **Lyria 2** - Music generation
- **Google Gemini 2.5** - Content generation and processing

**Backend & Infrastructure:**
- **Google Cloud Run** - Serverless container hosting
- **Google Cloud Storage** - Media file storage with signed URLs
- **Google Firestore** - NoSQL database for scenarios and user data
- **Google Cloud Build** - CI/CD pipeline
- **Google Artifact Registry** - Container image registry

**Media Processing:**
- **FFmpeg** - Server-side video concatenation, audio mixing, and overlay composition
- **Sharp** - High-performance image processing
- **Web Audio API** - Real-time audio waveform visualization

**Authentication & State Management:**
- **NextAuth.js 5** - Authentication with Google OAuth
- **TanStack Query** - Server state management and caching

### Application Flow

```
User Input → Story Generation → Scene Creation → Media Generation → Video Assembly → Export
     ↓              ↓               ↓              ↓                ↓           ↓
  Text Pitch → Gemini 2.5 → Structured → Imagen 4.0 → Timeline → FFmpeg → Final Video
                           Scenarios     Veo 3.0      Editor    Processing
                                        TTS/Music
```

## Project Structure

```
storycraft/
├── app/                          # Next.js App Router
│   ├── actions/                  # Server Actions
│   │   ├── generate-scenes.ts    # Story and scene generation
│   │   ├── generate-video.ts     # Video export with FFmpeg
│   │   ├── generate-music.ts     # Music generation with Lyria
│   │   ├── generate-voiceover.ts # TTS voice synthesis
│   │   ├── modify-scenario.ts    # Character/setting modifications
│   │   ├── resize-image.ts       # Image processing utilities
│   │   └── storageActions.ts     # GCS file operations
│   ├── api/                      # API Routes
│   │   ├── auth/                 # NextAuth endpoints
│   │   ├── videos/               # Video generation API
│   │   ├── regenerate-image/     # Image regeneration API
│   │   ├── scenarios/            # Scenario CRUD operations
│   │   └── users/                # User management
│   ├── components/               # React Components
│   │   ├── create/               # Story creation interface
│   │   ├── editor/               # Timeline-based video editor
│   │   ├── scenario/             # Story scenario management
│   │   ├── storyboard/           # Scene editing and management
│   │   ├── video/                # Video playback and export
│   │   └── ui/                   # Reusable UI components
│   ├── sign-in/                  # Authentication pages
│   ├── globals.css               # Global styles and CSS variables
│   ├── layout.tsx                # Root layout with providers
│   ├── page.tsx                  # Main application page
│   ├── types.ts                  # TypeScript type definitions
│   └── logger.ts                 # Winston logging configuration
├── lib/                          # Core Utilities
│   ├── veo.ts                    # Veo 3.0 video generation
│   ├── imagen.ts                 # Imagen 4.0 image generation
│   ├── gemini.ts                 # Gemini 2.5 content generation
│   ├── tts.ts                    # Text-to-Speech integration
│   ├── lyria.ts                  # Music generation
│   ├── ffmpeg.ts                 # Video processing utilities
│   ├── firestore.ts              # Database operations
│   ├── storage.ts                # Cloud Storage utilities
│   └── utils.ts                  # General utilities
├── components/ui/                # Shared UI Components
├── hooks/                        # Custom React Hooks
│   ├── use-auth.ts               # Authentication hook
│   └── use-scenario.ts           # Scenario management hook
├── public/                       # Static Assets
│   ├── music/                    # Background music library
│   ├── styles/                   # Visual style references
│   └── uploads/                  # User-uploaded content
├── terraform/                    # Infrastructure as Code
├── scripts/                      # Deployment Scripts
├── Dockerfile                    # Container configuration
└── auth.ts                       # NextAuth configuration
```

## Core Features & Components

### 1. Story Creation Workflow

**Components:** `app/components/create/`
- **CreateTab**: Main story creation interface
- **StyleSelector**: Visual style selection (Photographic, 2D Animation, Anime, etc.)
- **LanguageSelector**: Multi-language support for voiceovers
- **AspectRatioSelector**: Video format selection (16:9, 9:16, 1:1)

**Process:**
1. User inputs story pitch and parameters
2. Gemini 2.5 generates structured scenario with characters, settings, props
3. System creates detailed scene breakdowns with image/video prompts

### 2. Scene Management

**Components:** `app/components/storyboard/`
- **StoryboardTab**: Main scene management interface
- **SceneData**: Individual scene editing component
- **Multiple view modes**: Grid, List, Slideshow

**Features:**
- Drag-and-drop scene reordering
- Individual scene regeneration
- Image upload and replacement
- Real-time scene editing

### 3. Media Generation Pipeline

**AI Services Integration:**
- **Imagen 4.0**: High-quality image generation with style consistency
- **Veo 3.0**: Video generation from images with camera motion and audio
- **Chirp 3**: Neural voice synthesis with multiple voice options
- **Lyria 2**: Background music generation based on mood and genre

**Processing Flow:**
```
Text Prompt → Image Generation → Video Generation → Audio Synthesis → Final Assembly
```

### 4. Timeline Editor

**Components:** `app/components/editor/`
- **EditorTab**: Main timeline interface
- **TimelineEditor**: Drag-and-drop timeline with layers
- **AudioWaveform**: Real-time audio visualization
- **VideoPreview**: Synchronized video playback

**Features:**
- Multi-layer timeline (video, voiceover, music)
- Real-time preview with audio synchronization
- Logo overlay support
- Precise timing controls

### 5. Video Export System

**Technology:** FFmpeg with fluent-ffmpeg wrapper
**Process:**
1. Concatenate scene videos with transitions
2. Mix voiceover audio tracks
3. Add background music with fade effects
4. Apply logo overlays
5. Generate final MP4 with subtitles (VTT)

## Data Models

### Core Types (app/types.ts)

```typescript
interface Scenario {
  name: string
  pitch: string
  scenario: string
  style: string
  aspectRatio: string
  durationSeconds: number
  language: Language
  characters: Character[]
  settings: Setting[]
  props: Prop[]
  scenes: Scene[]
  music?: string
  musicUrl?: string
  logoOverlay?: string
}

interface Scene {
  imagePrompt: ImagePrompt
  videoPrompt: VideoPrompt
  description: string
  voiceover: string
  charactersPresent: string[]
  imageGcsUri?: string
  videoUri?: string
  voiceoverAudioUri?: string
}

interface TimelineLayer {
  id: string
  name: string
  type: 'video' | 'voiceover' | 'music'
  items: TimelineItem[]
}
```

## Authentication & Security

### NextAuth.js Configuration (auth.ts)

- **Provider**: Google OAuth 2.0
- **Session Management**: JWT with stable Google user IDs
- **Security Features**: CSRF protection, secure cookies
- **Authorization**: Route-based access control

### Security Measures

- **Service Account**: Dedicated GCP service account with minimal permissions
- **IAM Roles**: Principle of least privilege
- **Signed URLs**: Secure media file access
- **Environment Variables**: Sensitive configuration management

## Infrastructure & Deployment

### Google Cloud Platform Architecture

```
Internet → Cloud Load Balancer → Cloud Run → Vertex AI APIs
    ↓                              ↓           ↓
Cloud CDN                    Cloud Storage   Firestore
                                  ↓
                            Artifact Registry
```

### Terraform Infrastructure (terraform/)

**Resources Provisioned:**

1. **API Enablement**
   - Cloud Run, Cloud Build, Container Registry
   - Vertex AI Platform, Text-to-Speech, Translation
   - Firestore, Cloud Storage, IAM

2. **Service Account & IAM**
   ```hcl
   resource "google_service_account" "storycraft_service_account"
   # Roles: aiplatform.user, storage.objectAdmin, datastore.user
   ```

3. **Cloud Storage**
   ```hcl
   resource "google_storage_bucket" "storycraft_assets"
   # Features: CORS, lifecycle rules, uniform access
   ```

4. **Firestore Database**
   ```hcl
   resource "google_firestore_database" "storycraft_db"
   # Composite index for scenarios collection
   ```

5. **Cloud Run Service**
   ```hcl
   resource "google_cloud_run_v2_service" "storycraft_service"
   # Auto-scaling: 0-100 instances, 2 CPU, 4Gi memory
   ```

6. **Artifact Registry**
   ```hcl
   resource "google_artifact_registry_repository" "storycraft_repo"
   # Docker container registry
   ```

### Environment Variables

**Required Configuration:**
```bash
# Google Cloud
PROJECT_ID=your-gcp-project-id
LOCATION=us-central1
FIRESTORE_DATABASE_ID=storycraft-db
GCS_BUCKET_NAME=project-storycraft-assets
GCS_VIDEOS_STORAGE_URI=gs://bucket/videos/

# Authentication
NEXTAUTH_URL=https://your-cloud-run-url
NEXTAUTH_SECRET=your-secure-secret
AUTH_GOOGLE_ID=your-google-oauth-id
AUTH_GOOGLE_SECRET=your-google-oauth-secret

# Application
NODE_ENV=production
LOG_LEVEL=info
USE_COSMO=false
```

## Deployment Process

### Automated Deployment (scripts/)

**1. Infrastructure Setup (setup-terraform.sh)**
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

**2. Application Build & Deploy (build-and-deploy.sh)**
```bash
# Build Docker image
docker build -t $IMAGE_URI .

# Push to Artifact Registry
docker push $IMAGE_URI

# Deploy to Cloud Run
gcloud run deploy storycraft --image=$IMAGE_URI
```

### Manual Deployment Steps

1. **Prerequisites**
   - Google Cloud SDK installed and authenticated
   - Terraform >= 1.0
   - Docker for container builds

2. **Infrastructure Deployment**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   terraform init
   terraform apply
   ```

3. **Application Deployment**
   ```bash
   # Build and push container
   PROJECT_ID=$(terraform output -raw project_id)
   REGISTRY_URI=$(terraform output -raw container_image_uri)
   
   docker build -t $REGISTRY_URI/storycraft:latest .
   docker push $REGISTRY_URI/storycraft:latest
   
   # Update Terraform with image URI
   terraform apply
   ```

### Container Configuration (Dockerfile)

**Multi-stage Build:**
- **Base**: Node.js 23 Alpine with FFmpeg
- **Dependencies**: Install npm packages
- **Builder**: Build Next.js application
- **Runner**: Production container with minimal footprint

**Key Features:**
- FFmpeg installation for video processing
- Next.js standalone output for optimal performance
- Non-root user for security
- Optimized layer caching

## Performance & Scalability

### Cloud Run Configuration

- **Auto-scaling**: 0-100 instances based on demand
- **Resources**: 2 CPU cores, 4Gi memory per instance
- **Cold Start**: Optimized with Next.js standalone build
- **Cost**: Pay-per-request model with scale-to-zero

### Optimization Strategies

1. **Media Processing**: Asynchronous video generation with progress tracking
2. **Caching**: TanStack Query for client-side state management
3. **Image Optimization**: Sharp for server-side processing, Next.js Image component
4. **Database**: Firestore composite indexes for efficient queries
5. **Storage**: Cloud Storage with CDN for media delivery

### Monitoring & Logging

- **Winston Logger**: Structured logging with different levels
- **Cloud Logging**: Centralized log aggregation
- **Cloud Monitoring**: Performance metrics and alerting
- **Error Tracking**: Automatic error reporting and analysis

## Development Workflow

### Local Development

```bash
# Install dependencies
npm install

# Set up environment variables
cp .env.example .env.local

# Run development server
npm run dev
```

### Testing Strategy

- **Unit Tests**: Component and utility function testing
- **Integration Tests**: API endpoint testing
- **E2E Tests**: Full workflow testing with Playwright
- **Load Testing**: Performance testing with realistic scenarios

### CI/CD Pipeline

1. **Code Push**: Trigger Cloud Build on repository changes
2. **Build**: Create Docker container with application
3. **Test**: Run automated test suite
4. **Deploy**: Update Cloud Run service with new container
5. **Verify**: Health checks and smoke tests

## Security Considerations

### Data Protection

- **Encryption**: Data encrypted in transit and at rest
- **Access Control**: IAM-based resource access
- **Authentication**: OAuth 2.0 with secure session management
- **Content Filtering**: AI-generated content safety checks

### Compliance

- **GDPR**: User data handling and deletion capabilities
- **Content Policy**: Google AI content policy enforcement
- **Rate Limiting**: API usage limits and abuse prevention

## Cost Optimization

### Resource Management

- **Cloud Run**: Scale-to-zero for cost efficiency
- **Storage**: Lifecycle rules for automatic cleanup
- **AI APIs**: Optimized prompt engineering to reduce token usage
- **Monitoring**: Cost alerts and budget controls

### Estimated Costs (Monthly)

- **Cloud Run**: $10-50 (based on usage)
- **Cloud Storage**: $5-20 (media files)
- **Firestore**: $1-10 (document operations)
- **Vertex AI**: $50-200 (AI model usage)
- **Total**: $66-280 (varies with usage)

## Troubleshooting & Maintenance

### Common Issues

1. **Video Generation 404 Errors**: Check Vertex AI API endpoints and authentication
2. **Memory Issues**: Increase Cloud Run memory allocation for large videos
3. **Storage Permissions**: Verify service account IAM roles
4. **Authentication Failures**: Check OAuth configuration and secrets

### Monitoring Commands

```bash
# View service logs
gcloud logging read "resource.type=cloud_run_revision" --limit=50

# Check service status
gcloud run services describe storycraft --region=us-central1

# Monitor resource usage
gcloud monitoring metrics list --filter="resource.type=cloud_run_revision"
```

### Backup & Recovery

- **Database**: Firestore automatic backups
- **Storage**: Cross-region replication for media files
- **Configuration**: Infrastructure as Code with Terraform state
- **Disaster Recovery**: Multi-region deployment capability

## Future Enhancements

### Planned Features

1. **Advanced Editing**: More sophisticated timeline controls
2. **Collaboration**: Multi-user scenario editing
3. **Templates**: Pre-built story templates and themes
4. **Analytics**: Usage analytics and performance insights
5. **Mobile App**: React Native mobile application

### Technical Improvements

1. **Performance**: WebAssembly for client-side video processing
2. **Scalability**: Kubernetes deployment for high-volume usage
3. **AI Models**: Integration with latest Google AI models
4. **Real-time**: WebSocket-based real-time collaboration

This documentation provides a comprehensive overview of the StoryCraft application architecture, deployment process, and operational considerations. The system is designed for scalability, maintainability, and cost-effectiveness while leveraging cutting-edge AI technologies for creative content generation.